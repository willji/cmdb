#region helper functions

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

#endregion

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

# get all lbs
$htLbs = @{}
$lbs = Get-AllResult -Response (Invoke-RestMethod -Uri "http://guhuajun:8000/api/cmdb/devices/loadbalancer" -Method Get -Headers $headers -WebSession $webSession) -Header $headers -WebSession $webSession
foreach ($lb in $lbs)
{
    if ($lb.ipaddresses.count -ne 0)
    {
        if (!($htLbs.ContainsKey($lb.ipaddresses[0])))
        {
            $htLbs.Add($lb.ipaddresses[0], $lb.name)
        }
    }
}

# lb app mapping data
$upstreams = Import-Csv -Path D:\CorpDocs\nginx_upstreams.csv -Encoding UTF8
$applbs = @()
$upstreams | Group-Object -Property app | %{
    $applbs += [PSCustomObject]@{
        "name" = $PSItem.name
        "lbnames" = $PSItem.group.server | %{ $htLbs[$PSItem] }
    }
}

# update application group
foreach ($applb in $applbs)
{
    $jsonBody = ConvertTo-Json -InputObject $body
    
    $tempFile = [System.IO.Path]::GetTempFileName()
    $response = Invoke-RestMethod -Uri ("http://guhuajun:8000/api/cmdb/applications/applicationgroup?application__name={0}&environment__name=Production" -f $applb.name) -Method Get -Headers $headers -ContentType "application/json" -WebSession $webSession -OutFile $tempFile
    $response = ConvertFrom-Json (Get-Content -Path $tempFile -Encoding UTF8)
    if ($response.results.Count -ne 0)
    {
        $body = $response.results[0]
        $body.load_balancer = $applb.lbnames
        $body = $body | Select-Object -Property load_balancer
        
        $jsonBody = ConvertTo-Json -InputObject $body

        Invoke-RestMethod -Uri $response.results[0].url -Method Patch -Body $jsonBody -Headers $headers -ContentType "application/json" -WebSession $webSession
    }
    else
    {
        Write-Warning -Message ("Cannot find application group by name {0}" -f $applb.name)
    }

    Remove-Item -Path $tempFile
}