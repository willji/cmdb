$OutputEncoding = [System.Text.UTF8Encoding]::UTF8

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

function Get-AllResult
{
    param
    (
        [PSObject]$Response,
        [hashtable]$Header,
        [PSObject]$WebSession
    )
    
    foreach ($item in $Response.results)
    {
        Write-Output -InputObject $item
    }

    if ($Response.next -ne $null)
    {
        $tempFile = [System.IO.Path]::GetTempFileName()
        $subResponse = Invoke-RestMethod -Uri $Response.next -Method Get -Headers $Header -ContentType "application/json" -WebSession $WebSession -OutFile $tempFile
        $subResponse = ConvertFrom-Json -InputObject (Get-Content -Path $tempFile -Encoding UTF8 -Raw)
        Get-AllResult -Response $subResponse -Header $Header -WebSession $WebSession
        Remove-Item -Path $tempFile
    }
}

function Update-Data
{
    param
    (
        [string]$Uri,
        [string]$Filter,
        [hashtable]$Header,
        [string]$JsonBody,
        [PSObject]$WebSession
    )

    $response = Invoke-RestMethod -Uri ("{0}?{1}" -f $Uri, $Filter) -Method Get -Headers $Header -WebSession $WebSession
    # Creating a new item or updating an existing item.
    if ($response.count -eq 0)
    {
        $response = Invoke-RestMethod -Uri $Uri -Method Post -Headers $Header -Body $JsonBody -ContentType "application/json" -WebSession $WebSession
    }
    else
    {
        $response = Invoke-RestMethod -Uri $response.results[0].url -Method Put -Headers $Header -Body $JsonBody -ContentType "application/json" -WebSession $WebSession
    }
}

function New-RequestBody
{
    param
    (
        [psobject]$InputObject,
        [string[]]$ArrayProperty,
        [hashtable]$FixData,
        [switch]$ForceFixData
    )

    $excludeFields = @("url", "created_date", "modified_date")

    $result = @{}
    $properties = @()

    $tempObject = $InputObject | Select-Object -Property * -ExcludeProperty $excludeFields
    $tempObject | Get-Member -MemberType NoteProperty | %{$properties += $PSItem.Name }
        
    # Remove empty properties
    foreach ($property in $properties)
    {
        # Handling array property
        if ($property -in $ArrayProperty)
        {
            $tempList = @()
            
            if (![string]::IsNullOrEmpty($tempObject.$property))
            {
                $tempObject.$property | %{ $tempList += ConvertTo-Unicode -InputObject $PSItem }
            }

            $result.Add($property, $tempList)
            continue
        }

        if (![string]::IsNullOrEmpty($tempObject.$property))
        {
            $value = ConvertTo-Unicode -InputObject $tempObject.$property
            $result.Add($property, $value.Trim())
        }
    }

    # Fix Data
    if ($FixData.Count -gt 0)
    {
        foreach ($item in $FixData.GetEnumerator())
        {
            $value = ConvertTo-Unicode -InputObject $item.value
            
            # We only need to fix data for some items, which means the '$result' item does not have the key (field name)
            if (!$result.ContainsKey($item.key))
            {
                $result.Add($item.key, $value)
            }
            else
            {
                if ($ForceFixData)
                {
                    $result.Remove($item.key)
                    $result.Add($item.key, $value)
                }
            }
        }
    }

    return $result
}

function Get-CsrfToken
{
    param
    (
        [string]$Uri,
        [string]$Username,
        [string]$Password
    )

    $webResponse = Invoke-WebRequest -Uri $Uri -SessionVariable script:webSession3
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
    $webResponse = Invoke-WebRequest -Uri $Uri -Method Post -Body $body -WebSession $webSession3 -MaximumRedirection 0 -ErrorAction Ignore

    # Get new token and sessionid
    return $webResponse.BaseResponse.Cookies['csrftoken'].Value
}

#endregion

#region Main Functions

function Sync-Data
{
    param
    (
        [string]$ItemName,
        [string]$SourceUri,
        [string]$DestinationUri,
        [string[]]$ArrayProperty,
        [hashtable]$FixData
    )

    # Why using OutFile parameter
    # http://stackoverflow.com/questions/17705968/encoding-of-the-response-of-the-invoke-webrequest

    $tempFile = [System.IO.Path]::GetTempFileName()

    # CMDB V1
    Write-Log -Path $logFilePath -Component "SYNC" -MessageType INFO -Message "CMDBV1: Retrieving $ItemName ..." -Indent 2
    $response = Invoke-RestMethod -Uri ("{0}{1}" -f $cmdbv1RootUri, $SourceUri) -Method Get -Headers $header1 -ContentType "application/json" -WebSession $webSession1 -OutFile $tempFile
    $response = ConvertFrom-Json -InputObject (Get-Content -Path $tempFile -Encoding UTF8 -Raw)
    $results = Get-AllResult -Response $response -Header $header1 -WebSession $webSession1
    $resultsCount = ($results | Measure-Object).Count
    Write-Log -Path $logFilePath -Component "SYNC" -MessageType INFO -Message ("CMDBV1: {0} objects are retrieved." -f $resultsCount) -Indent 2

    # CMDB V2
    Write-Log -Path $logFilePath -Component "SYNC" -MessageType INFO -Message "CMDBV2: Updating $ItemName ..." -Indent 2
    foreach ($result in $results)
    {
        $body = New-RequestBody -InputObject $result -ArrayProperty $ArrayProperty -FixData $FixData
        $jsonBody = ConvertTo-Json -InputObject $body
        $jsonBody = $jsonBody.Replace("\\", "\")
        $response = Update-Data -Uri ("{0}{1}" -f $cmdbv2RootUri, $DestinationUri) -Filter ("name={0}" -f $result.name) -Header $header2 -JsonBody $jsonBody -WebSession $webSession2
    }
    Write-Log -Path $logFilePath -Component "SYNC" -MessageType INFO -Message ("CMDBV2: {0} objects are updated." -f $resultsCount) -Indent 2

    Remove-Item -Path $tempFile
}

#endregion

# Main entry

# Script variables
$script:webSession1    = $null
$script:webSession2    = $null
$script:webSession3    = $null
$script:cmdbv1RootUri  = "http://cmdb.ops.ymatou.cn"
$script:cmdbv1LoginApi = "{0}/api/cmdb/token/" -f $cmdbv1RootUri
$script:cmdbv2RootUri  = "http://cmdb_v2.ops.ymatou.cn"
$script:cmdbv2LoginApi = "{0}/api/cmdb/token/" -f $cmdbv2RootUri
$script:releaseRootUri  = "http://release.ops.ymatou.cn"
$script:releaseLoginApi = "{0}/api/token/" -f $releaseRootUri
$script:cmdbv1Token    = $null
$script:cmdbv2Token    = $null
$script:releaseToken   = $null
$script:header1        = $null
$script:header2        = $null
$script:header3        = $null

# Split log file per day. 
$script:logFilePath = Join-Path -Path $PSScriptRoot -ChildPath ("CMDBDataSync_{0}.log" -f (Get-Date -Format "yyyyMMdd"))

# get web apps list (including ip addresses) from release system.
Write-Log -Path $logFilePath -Component "Main" -MessageType INFO -Message "========= Job Start ========="

#region Get Tokens

try
{
    Write-Log -Path $logFilePath -Component "Main" -MessageType INFO -Message "Retrieving tokens ..."

    # Prepare authentication
    $body1 = @{
        "username" = "opsadmin";
        "password" = "Welcome123";
    }

    $body2 = @{
        "username" = "opsadmin";
        "password" = "cmdb@ymt8102";
    }

    $body3 = @{
        "username" = "root";
        "password" = "Welcome123";
    }

    # Get new token and sessionid
    $jsonBody = ConvertTo-Json -InputObject $body1
    $response = Invoke-RestMethod -Uri $cmdbv1LoginApi -Method Post -Body $jsonBody -ContentType "application/json" -WebSession $webSession1
    $cmdbv1Token = $response.token

    $jsonBody = ConvertTo-Json -InputObject $body2
    $response = Invoke-RestMethod -Uri $cmdbv2LoginApi -Method Post -Body $jsonBody -ContentType "application/json" -WebSession $webSession2
    $cmdbv2Token = $response.token

    $jsonBody = ConvertTo-Json -InputObject $body3
    $response = Invoke-RestMethod -Uri $releaseLoginApi -Method Post -Body $jsonBody -ContentType "application/json" -WebSession $webSession3
    $releaseToken = $response.token    

    # Prepare authentication header
    $header1 = @{
        "Authorization" = "Token $cmdbv1Token";
    }

    $header2 = @{
        "Authorization" = "Token $cmdbv2Token";
    }

    $header3 = @{
        "Authorization" = "Token $releaseToken";
    }

}
catch
{
    Write-Log -Path $logFilePath -Component "TOKEN" -MessageType ERROR -Message $PSItem.Exception.Message
    exit 1
}

#endregion

#region Sync data from CMDBV1 to CMDBV2

#Sync items
try
{
    # asset    
    # Sync-Data -ItemName "asset type" -SourceUri "/api/cmdb/assets/assettypes" -DestinationUri "/api/cmdb/assets/assettype" -ArrayProperty @() -FixData @{}
    # Sync-Data -ItemName "asset status" -SourceUri "/api/cmdb/assets/assetstatus" -DestinationUri "/api/cmdb/assets/assetstatus" -ArrayProperty @() -FixData @{}
    # Sync-Data -ItemName "asset specification" -SourceUri "/api/cmdb/assets/serverspcifications" -DestinationUri "/api/cmdb/assets/assetspcification" -ArrayProperty @() -FixData @{}

    # people        
    # Sync-Data -ItemName "people" -SourceUri "/api/cmdb/contact/people" -DestinationUri "/api/cmdb/contacts/contact" -ArrayProperty @() -FixData @{}

    # environement
    # Sync-Data -ItemName "environment" -SourceUri "/api/cmdb/webapps/environment" -DestinationUri "/api/cmdb/environments/environment" -ArrayProperty @() -FixData @{}
    # Sync-Data -ItemName "location" -SourceUri "/api/cmdb/devices/location" -DestinationUri "/api/cmdb/environments/location" -ArrayProperty @() -FixData @{}

    # network
    # Sync-Data -ItemName "ipv4 network" -SourceUri "/api/cmdb/networks/ipv4networks" -DestinationUri "/api/cmdb/networks/ipv4network" -ArrayProperty @() -FixData @{}

    # device
    # os type
    # Sync-Data -ItemName "os type" -SourceUri "/api/cmdb/devices/ostype" -DestinationUri "/api/cmdb/devices/ostype" -ArrayProperty @() -FixData @{}

    # has foreign/multiple relationship
    # Add department, device status manually
    # asset
    <#
    $assetFixData = @{
        "department" = "ops";
        "owner" = "万钧";
        "specification" = "惠普服务器";
    }
    Sync-Data -ItemName "asset" -SourceUri "/api/cmdb/assets/asset" -DestinationUri "/api/cmdb/assets/asset" -ArrayProperty @("dc_contact", "vendor_contact") -FixData $assetFixData
    #>
      
    # physical server
    <#
    $serverFixData = @{
        "status" = "正常";
    }
    Sync-Data -ItemName "physical server" -SourceUri "/api/cmdb/devices/physicalserver" -DestinationUri "/api/cmdb/devices/physicalserver" -ArrayProperty @("ipaddresses") -FixData $serverFixData
    #>

    # application name
    # get application name from release system

    $applications = Get-AllResult -Response (Invoke-RestMethod -Uri ("{0}/api/cmdb/webapps/webapp" -f $cmdbv1RootUri) -Method Get -Headers $header1 -WebSession $webSession1) -Header $header1 -WebSession $webSession1
    $tempFile = [System.IO.Path]::GetTempFileName()

    # get app names
    $response = Invoke-RestMethod -Uri "http://release.ops.ymatou.cn/api/dep_detail/" -Method Get -Headers $header3 -WebSession $webSession3 -OutFile $tempFile
    $content = Get-Content -Path $tempFile -Encoding UTF8 -Raw
    $content = $content.Replace("架构", "infra")
    $appNames = ConvertFrom-Json -InputObject $content

    # get app type
    $response = Invoke-RestMethod -Uri "http://release.ops.ymatou.cn/api/item/" -Method Get -Headers $header3 -WebSession $webSession3 -OutFile $tempFile
    $content = Get-Content -Path $tempFile -Encoding UTF8 -Raw
    $appTypes = ConvertFrom-Json -InputObject $content

    # get release apps
    $releaseApps = @{}
    foreach ($appName in $appNames)
    {
        $application = @{
            "department"  = $appName.dep;
            "type"        = ($appTypes | ?{$PSItem.content -eq $appName.item}).type;
            "alias"       = ($appTypes | ?{$PSItem.content -eq $appName.item}).alias;
        }
        
        if (!$releaseApps.ContainsKey($appName.item))
        {
            $releaseApps.Add($appName.item, $application)
        }
    }

    # application
    # get application from cmdbv1
    # prepare request body and post data for application
    foreach ($application in $applications)
    {
        # Update or create application
        $applicationBody = [PSCustomObject]@{
            "name"        = $application.name;
            "department"  = if ($releaseApps[$application.name].department) { $releaseApps[$application.name].department } else { "m2c" };
            "type"        = $releaseApps[$application.name].type;
            "alias"       = $releaseApps[$application.name].alias;
            "owner"       = ConvertTo-Unicode -InputObject "王思俊";
            "warmup_urls" = @{};
        }
        $jsonBody = ConvertTo-Json -InputObject $applicationBody
        $jsonBody = $jsonBody.Replace("\\", "\")
        Update-Data -Uri ("{0}/api/cmdb/applications/application" -f $cmdbv2RootUri) -Filter ("name={0}" -f $application.name.Trim()) -Header $header2 -JsonBody $jsonBody -WebSession $webSession2
    }
    
    # prepart request body and post data for application group
    foreach ($application in $applications)
    {
        # Update or create application
        $applicationBody = [PSCustomObject]@{
            "application" = $application.name;
            "location"    = ConvertTo-Unicode -InputObject "外高桥IDC6";
            "environment" = $application.environment;
            "ipaddresses" = $application.ipaddresses;
        }
        $jsonBody = ConvertTo-Json -InputObject $applicationBody
        $jsonBody = $jsonBody.Replace("\\", "\")
        Update-Data -Uri ("{0}/api/cmdb/applications/applicationgroup" -f $cmdbv2RootUri) -Filter ("application__name={0}&environment__name={1}&location__name={2}" -f $application.name, $application.environment, "外高桥IDC6" ) -Header $header2 -JsonBody $jsonBody -WebSession $webSession2
    }
    
    # application history
    # get application history from release system
    <#
    $releaseLoginApi = "http://{0}:{1}/api/api-auth/login/" -f @("release.ops.ymatou.cn", 80)
    
    $header3 = @{
        "X-CSRFToken" = Get-CsrfToken -Uri $releaseLoginApi -Username root -Password Welcome123;
    }

    # get app release history
    $tempFile = [System.IO.Path]::GetTempFileName()
    $response = Invoke-RestMethod -Uri "http://release.ops.ymatou.cn/api/version.json" -Method Get -Headers $header3 -WebSession $webSession3 -OutFile $tempFile
    $content = Get-Content -Path $tempFile -Encoding UTF8 -Raw
    $content = $content.Replace("stg", "Staging").Replace("pro", "Production")
    $historyItems = ConvertFrom-Json -InputObject $content

    # prepart request body and post data
    foreach ($historyItem in $historyItems)
    {
        $body = [PSCustomObject]@{
            "application_group" = "{0}_{1}_{2}" -f @($historyItem.item.ToLower(), $historyItem.env, 1);
            "task_id"     = $historyItem.mission;
            "version"     = if ($historyItem.version.Length -gt 20) { "" } else { $historyItem.version };
        }
        
        $jsonBody = ConvertTo-Json -InputObject $body
        $jsonBody = $jsonBody.Replace("\\", "\")

        # if cannot find app, skip that history.
        $response = Invoke-RestMethod -Uri ("{0}/api/cmdb/applications/application?name={1}" -f $cmdbv2RootUri, $historyItem.item.ToLower()) -Method Get -Headers $header2 -WebSession $webSession2
        if ($response.count -eq 0)
        {
            continue
        }

        $response = Invoke-RestMethod -Uri ("{0}/api/cmdb/applications/applicationhistory" -f $cmdbv2RootUri) -Method Post -Header $header2 -Body $jsonBody -ContentType "application/json" -WebSession $webSession2
    }
    #>
    
    # switch
    # get switchs/firewalls/lb from cmdbv1, add lbtype manually
    <#
    $tempFile = [System.IO.Path]::GetTempFileName()
    $response = Invoke-RestMethod -Uri ("{0}/api/cmdb/devices/switch" -f $cmdbv1RootUri) -Method Get -Headers $header1 -WebSession $webSession1 -OutFile $tempFile
    $response = ConvertFrom-Json -InputObject (Get-Content -Path $tempFile -Encoding UTF8)
    $switches = Get-AllResult -Response $response -Header $header1 -WebSession $webSession1
    Remove-Item -Path $tempFile
    foreach ($swdev in $switches)
    {
        $swdev | Add-Member -MemberType NoteProperty -Name status -Value (ConvertTo-Unicode -InputObject "正常")
        $swdev = $swdev | Select-Object -Property *, @{name="location"; expression={ ConvertTo-Unicode -InputObject $PSItem.location }}, @{name="description"; expression={ ConvertTo-Unicode -InputObject $PSItem.description }} -ExcludeProperty location, description, url
        
        # add switch, firewall, lb, vpn to different list in CMDBV2
        switch -Regex ($swdev.name)
        {
            "fw" {
                $targetUrl = "{0}/api/cmdb/devices/firewall" -f $cmdbv2RootUri
            }
            "lb" {
                $targetUrl = "{0}/api/cmdb/devices/loadbalancer" -f $cmdbv2RootUri
                $swdev | Add-Member -MemberType NoteProperty -Name type -Value "netscaler"
            }
            "vpn" {
                $targetUrl = "{0}/api/cmdb/devices/vpn" -f $cmdbv2RootUri
            }
            default {
                $targetUrl = "{0}/api/cmdb/devices/switch" -f $cmdbv2RootUri
            }
        }

        $jsonBody = ConvertTo-Json -InputObject $swdev
        $jsonBody = $jsonBody.Replace("\\", "\")

        Update-Data -Uri $targetUrl -Filter ("name={0}" -f $swdev.name) -Header $header2 -WebSession $webSession2 -JsonBody $jsonBody
    }    
    #>

    # No sync
    # department, device status
    # create manually
}
catch
{
    Write-Log -Path $logFilePath -Component "SYNC" -MessageType ERROR -Message $PSItem.Exception.Message -EnableStdErr
    exit 1
}

#endregion

Write-Log -Path $logFilePath -Component "Main" -MessageType INFO -Message "========== Job End =========="
exit 0
