# block running this script.
exit 0

$webSession   = $null
$computerName = "cmdb.ops.ymatou.cn"
$port         = "80"
$userName     = "opsadmin"
$password     = "Welcome123"
$loginURI     = ("http://{0}:{1}/api/cmdb/token/" -f @($computerName, $port))

# Prepare authentication
$body = @{
    "username" = $userName;
    "password" = $password;
}

$jsonBody = ConvertTo-Json -InputObject $body
$response = Invoke-RestMethod -Uri $loginURI -Method Post -Body $jsonBody -ContentType "application/json" -WebSession $webSession

# Get new token and sessionid
$csrfToken = $response.token

# create or update application tags

$headers = @{
    "Authorization" = "Token $csrfToken";
}

function GetResults
{
    param
    (
        [PSObject]$Response
    )

    $headers = @{
        "Authorization" = "Token $csrfToken";
    }
    
    foreach ($item in $Response.results)
    {
        Write-Output -InputObject $item
    }

    if ($Response.next -ne $null)
    {
        GetResults -Response (Invoke-RestMethod -Uri $Response.next -Method Get -Headers $headers -ContentType "application/json" -WebSession $webSession)
    }
}

$headers = @{
    "Authorization" = "Token $csrfToken";
}

$oldAppName = "jsapi.app.ymatou.com"
$newAppName = "ms.jsapi.app.ymatou.com"
$response = Invoke-RestMethod -Uri ("http://{0}:{1}/api/cmdb/passwords/password?application__name={2}" -f @($computerName, $port, $oldAppName)) -Method Get -Headers $headers -ContentType "application/json" -WebSession $webSession
$results = GetResults -Response $response

foreach ($result in $results)
{
    $body = @{
        "application" = $newAppName
        "gitlab_path" = $result.gitlab_path.Replace($oldAppName, $newAppName)
        "relative_path" = $result.relative_path
        "line" = $result.line
        "password" = $result.password
        "passwordMD5" = $result.passwordMD5
    }

    $jsonBody = ConvertTo-Json -InputObject $body
    Invoke-RestMethod -Uri ("http://{0}:{1}/api/cmdb/passwords/password" -f @($computerName, $port, $oldAppName)) -Method Post -Headers $headers -Body $jsonBody -ContentType "application/json" -WebSession $webSession
}