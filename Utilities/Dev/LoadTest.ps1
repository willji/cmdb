$url = "http://guhuajun:8000/api/cmdb/networks/ipv4network.json"

$webSession   = $null
$computerName = "guhuajun"
$port         = "8000"
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

$headers = @{
    "Authorization" = "Token $csrfToken";
}


workflow Test-WebPerformance
{
    param
    (
        [int]$Concurrent,
		[hashtable]$Header,
        [string]$Url
    )

    $items = 1..$Concurrent
    foreach -parallel ($item in $items)
    {
        Measure-Command -Expression { Invoke-RestMethod -Uri $Url -Method Get -Headers $Header }
    }
}

1..10 | %{ Test-WebPerformance -Concurrent 5 -Url $url -Header $headers } | Measure-Object -Property TotalMilliseconds -Average -Minimum -Maximum 
# | Export-Csv -Path ".\GetCountryGroupList.csv" -Append -NoTypeInformation