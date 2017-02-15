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
$cmdbLoginApi = "{0}/api/cmdb/token/" -f $cmdbRootUri

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
    exit 1
}

$response = Invoke-RestMethod -Uri $cmdbLoginApi -Method Post -Body (ConvertTo-Json -InputObject @{"username"="opsadmin"; "password"="Welcome123"}) -ContentType "application/json"
$token = $response.token
$headers = @{
    "Authorization" = "Token $token";
}

$groupedItems = $appLists | Group-Object -Property item

foreach ($groupedItem in $groupedItems)
{
    $childGroupedItems = $groupedItem.Group | Group-Object -Property env
    foreach ($childGroupedItem in $childGroupedItems)
    {
            
        $name = $groupedItem.Name
        $response = Invoke-RestMethod -Uri "http://cmdb.ops.ymatou.cn/api/cmdb/webapps/webapp?name=$name" -Headers $headers -Method Get -ContentType "application/json" -WebSession $webSession
        if ($childGroupedItem.Name -eq "stg")
        {
            $result = $response.results | ?{$PSItem.environment -eq "Staging"}
            $envName = "Staging"
        }
        else
        {
            $result = $response.results | ?{$PSItem.environment -eq "Production"}
            $envName = "Production"
        }
        $releaseIPNums = $childGroupedItem.Group.Count
        $cmdbIPNums = $result.ipaddresses.count

        $result = [PSCustomObject]@{
            "Name"         = $name;
            "Env"          = $envName;
            "ReleaseCount" = $releaseIPNums;
            "CmdbCount"    = $cmdbIPNums;
        }

        Write-Output -InputObject $result
    }
}
