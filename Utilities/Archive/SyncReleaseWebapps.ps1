#region Utility functions

function Write-Log
{   
    param
    (
        [Parameter(Mandatory = $true, Position = 0)]
        [string]
        $Path,

        [Parameter(Mandatory = $true, Position = 1)]
        [string]
        $Component,

        [Parameter(Mandatory = $true, Position = 2)]
        [AllowEmptyString()]
        [string]
        $Message,

        [Parameter(Mandatory = $false, Position = 3)]
        [ValidateSet("NONE", "INFO", "WARNING", "ERROR")]
        $MessageType,

        [Parameter(Mandatory = $false, Position = 4)]
        [int]
        $Indent = 0,

        [Parameter(Mandatory = $false)]
        [switch]
        $EnableStdOut,

        [Parameter(Mandatory = $false)]
        [switch]
        $EnableStdErr
    )

    process
    {
        # Using CMTrace format to make sure CMTrace can display the log file correctly.
        #   {0}: Log Text
        #   {1}: Component
        #   {2}/{3}: Datetime
        #   {4}: Thread/Process ID
        
        if ([string]::IsNullOrEmpty($Message)) { return $null }

        if ($MessageType -ne "NONE")
        {
            $logText = "{0}[{1}][{2}]" -f (" " * $Indent), $MessageType, $Message
        }
        else
        {
            $logText = $Message
        }

        # $dmtfDateTime = [System.Management.ManagementDateTimeConverter]::ToDmtfDateTime([datetime]::Now)
        $date = Get-Date -Format "MM-dd-yyyy"
        $time = Get-Date -Format "HH:mm:ss.ffffff"
        $msg = "{0} `$$<{1}><{2} {3}><thread={4}>" -f $logText, $Component, $date, $time, $PID
        Out-File -InputObject $msg -FilePath $Path -Encoding utf8 -Append

        if ($EnableStdOut) { Out-Default -InputObject $logText }
        if ($EnableStdErr) { Write-Error -Message $logText }
    }
}

function ConvertTo-Unicode
{
    param
    (
        [string]$InputObject
    )

    $sb = New-Object -TypeName System.Text.StringBuilder
    foreach ($chr in $InputObject.ToCharArray())
    {
        [void]$sb.Append("\u");
        [void]$sb.Append([String]::Format("{0:x4}", [int]$chr));
    }
    return $sb.ToString()
}

function Get-CsrfToken
{
    param
    (
        [string]$Uri,
        [string]$Username,
        [string]$Password
    )

    $webResponse = Invoke-WebRequest -Uri $Uri -SessionVariable script:webSession
    $csrfToken   = $webResponse.BaseResponse.Cookies['csrftoken'].Value

    # Prepare authentication
    $body = @{
        "csrfmiddlewaretoken" = $csrfToken;
        "username"            = $UserName;
        "password"            = $Password;
        "next"                = '/'
        'submit'              = 'Log in'
    }

    # Turn off auto redirection to get seesionid, this requires you user name and password is correct. Otherwise you will get a HTTP 200 (Loogin failed).
    $webResponse = Invoke-WebRequest -Uri $Uri -Method Post -Body $body -WebSession $webSession -MaximumRedirection 0 -ErrorAction Ignore

    # Get new token and sessionid
    return $webResponse.BaseResponse.Cookies['csrftoken'].Value
}

#endregion


# Main entry
$script:webSession = $null
$releaseLoginApi = "http://{0}:{1}/api/api-auth/login/" -f @("release.ops.ymatou.cn", 80)
$cmdbRootUri = "http://cmdb.ops.ymatou.cn"
$cmdbLoginApi = "{0}/api/cmdb/api-auth/login/" -f $cmdbRootUri


# Split log file per day. 
$logFilePath = Join-Path -Path $PSScriptRoot -ChildPath ("Sync_{0}.log" -f (Get-Date -Format "yyyyMMdd"))

# get web apps list (including ip addresses) from release system.
Write-Log -Path $logFilePath -Component "Main" -MessageType INFO -Message "========== Job Start =========="
Write-Log -Path $logFilePath -Component "Main" -MessageType INFO -Message "Retrieving data from release system ..."

$appLists = $null
try
{
    $headers = @{
        "X-CSRFToken" = Get-CsrfToken -Uri $releaseLoginApi -Username root -Password Welcome123;
    }
    $appLists = Invoke-RestMethod -Uri "http://release.ops.ymatou.cn/api/list/" -Method Get -Headers $headers -WebSession $webSession
}
catch
{
    Write-Log -Path $logFilePath -Component "Release" -MessageType ERROR -Message $PSItem.Exception.Message
    exit 1
}

try
{
    $groupedItems = $appLists | Group-Object -Property item

    $headers = @{
        "X-CSRFToken" = Get-CsrfToken -Uri $cmdbLoginApi -Username opsadmin -Password Welcome123;
    }

    foreach ($groupedItem in $groupedItems)
    {
        if ($groupedItem.Name -ne "jsapi.pk.ymatou.com") { continue }

        $childGroupedItems = $groupedItem.Group | Group-Object -Property env
        foreach ($childGroupedItem in $childGroupedItems)
        {
            $result = [PSCustomObject]@{
                "name" = $groupedItem.name;
                "ipaddresses" = @($childGroupedItem.Group.host | Select-Object -Unique | Sort-Object);
                "owner"       = ConvertTo-Unicode -InputObject "ÍõË¼¿¡";
                "environment" = if ($childGroupedItem.Group[0].env -eq "stg") { "Staging" } else { "Production" };
                # Test only since CMDB does not update in PROD.
                # "alias"       = $groupedItem.Name;
            }

            # Test web app existence
            $response = Invoke-RestMethod -Uri ("{0}/api/cmdb/webapps/webapp?name={1}" -f @($cmdbRootUri, $result.Name)) -Method Get -Headers $headers -ContentType "application/json" -WebSession $webSession
            $webApp = $response.results | ?{$PSItem.environment -eq $result.environment}

            if (!$webApp)
            {
                # Create web app
                Write-Log -Path $logFilePath -Component "CMDB" -MessageType INFO -Message ("Creating {0}: {1}..." -f @($result.environment, $result.name)) -Indent 2
                $result | Add-Member -NotePropertyName "package_url" -NotePropertyValue ""
                $result | Add-Member -NotePropertyName "config_url" -NotePropertyValue ""
                $jsonBody = (ConvertTo-Json -InputObject $result).Replace("\\", "\")
                $response = Invoke-RestMethod -Uri ("{0}/api/cmdb/webapps/webapp" -f $cmdbRootUri) -Method Post -Headers $headers -Body $jsonBody -ContentType "application/json" -WebSession $webSession
            }
            else
            {
                # Update web app
                Write-Log -Path $logFilePath -Component "CMDB" -MessageType INFO -Message ("Updating {0}: {1}..." -f @($result.environment, $result.name)) -Indent 2
                $url = $webApp.url
                $result | Add-Member -NotePropertyName "package_url" -NotePropertyValue $webApp.package_url
                $result | Add-Member -NotePropertyName "config_url" -NotePropertyValue $webApp.config_url
                $jsonBody = (ConvertTo-Json -InputObject $result).Replace("\\", "\")
                $response = Invoke-RestMethod -Uri $url -Method Put -Headers $headers -Body $jsonBody -ContentType "application/json" -WebSession $webSession
                Write-Log -Path $logFilePath -Component "CMDB" -MessageType INFO -Message ("{0}: {1} is updated." -f @($result.environment, $webApp.name)) -Indent 2
            }    
        }
    }
}
catch
{
    Write-Log -Path $logFilePath -Component "CMDB" -MessageType ERROR -Message $PSItem.Exception.Message
    exit 1
}

Write-Log -Path $logFilePath -Component "Main" -MessageType INFO -Message "========== Job End =========="
exit 0
