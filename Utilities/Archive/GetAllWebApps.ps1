# block running this script.
# exit 0

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
$response = Invoke-RestMethod -Uri ("http://{0}:{1}/api/cmdb/webapps/webapp" -f @($computerName, $port)) -Method Get -Headers $headers -ContentType "application/json" -WebSession $webSession
$results = GetResults -Response $response

$results | Select-Object -Property name, environment, @{"name"="NumberOfServers"; expression={$PSItem.ipaddresses.count}}, @{"name"="IP"; expression={$PSItem.ipaddresses -join ";"}} | Export-Csv -Path D:\Temp\webapps.csv -NoTypeInformation