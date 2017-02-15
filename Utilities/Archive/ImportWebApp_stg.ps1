# Block running this script.
exit 0

$webSession = $null

$computerName = "cmdb.ops.ymatou.cn"
$port = "80"
# $computerName = "cmdb.guhuajun.ymt.corp"
# $port = "18000"
$userName = "opsadmin"
$password = "Welcome123"

# TempAuth
# $loginURI = ("http://{0}:{1}/api/api-auth/login/" -f @($computerName, $port))

# PROD
$loginURI = ("http://{0}:{1}/api/cmdb/api-auth/login/" -f @($computerName, $port))

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

# Get token

$webResponse = Invoke-WebRequest -Uri $loginURI -SessionVariable webSession
$csrfToken   = $webResponse.BaseResponse.Cookies['csrftoken'].Value

# Prepare authentication
$body = @{
    "csrfmiddlewaretoken" = $csrfToken;
    "username"            = $userName;
    "password"            = $password;
    "next"                = '/'
    'submit'              = 'Log in'
}

# Turn off auto redirection to get seesionid, this requires you user name and password is correct. Otherwise you will get a HTTP 200 (Loogin failed).
$webResponse = Invoke-WebRequest -Uri $loginURI -Method Post -Body $body -WebSession $webSession -MaximumRedirection 0 -ErrorAction Ignore

# Get new token and sessionid
$csrfToken = $webResponse.BaseResponse.Cookies['csrftoken'].Value
$sessionid = $webResponse.BaseResponse.Cookies['sessionid'].Value

# Web apps list from Release system.
$content = Get-Content D:\Temp\release_webapps.json | ConvertFrom-Json
$groupedItems = $content | ?{$PSItem.env -eq "stg"} | Group-Object -Property item

$headers = @{
    "X-CSRFToken" = $csrfToken;
}

foreach ($groupedItem in $groupedItems)
{
    $result = [PSCustomObject]@{
        "name" = $groupedItem.Name;
        "ipaddresses" = @($groupedItem.Group.host | Select-Object -Unique | Sort-Object);
        "owner"       = ConvertTo-Unicode -InputObject "ÍõË¼¿¡";
        "environment" = "Staging";
        # Test only since CMDB does not update in PROD.
        # "alias"       = $groupedItem.Name;
    }

    # Test web app existence
    $response = Invoke-RestMethod -Uri ("http://{0}:{1}/api/cmdb/webapps/webapp?name={2}" -f @($computerName, $port, $result.Name)) -Method Get -Headers $headers -ContentType "application/json" -WebSession $webSession
    if ($response.results[0].environment -eq $result.environment)
    {
        $isExisted = $true
    }
    else
    {
        $isExisted = $false
    }

    if (!$isExisted)
    {
        # Create web app
        $result | Add-Member -NotePropertyName "package_url" -NotePropertyValue ""
        $result | Add-Member -NotePropertyName "config_url" -NotePropertyValue ""
        $jsonBody = (ConvertTo-Json -InputObject $result).Replace("\\", "\")
        $response = Invoke-RestMethod -Uri ("http://{0}:{1}/api/cmdb/webapps/webapp" -f @($computerName, $port)) -Method Post -Headers $headers -Body $jsonBody -ContentType "application/json" -WebSession $webSession
    }
    else
    {
        # Update web app
        $url = $response.results[0].url
        $result | Add-Member -NotePropertyName "package_url" -NotePropertyValue $response.results[0].package_url
        $result | Add-Member -NotePropertyName "config_url" -NotePropertyValue $response.results[0].config_url
        $jsonBody = (ConvertTo-Json -InputObject $result).Replace("\\", "\")
        $response = Invoke-RestMethod -Uri $url -Method Put -Headers $headers -Body $jsonBody -ContentType "application/json" -WebSession $webSession
    }
}