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

# resource pool data
$resourcePoolNames = @("m2c", "c2c", "infra", "xlobo", "ops", "test")
foreach ($resourcePoolName in $resourcePoolNames)
{
    $name = "{0} resource pool" -f $resourcePoolName
    $resourceUri = "api/cmdb/resourcepools/resourcepool"
    $response = Invoke-RestMethod -Uri ("http://{0}:{1}/{2}?name={3}" -f @($computerName, $port, $resourceUri, $name)) -Method Get -Headers $headers -ContentType "application/json" -WebSession $webSession
    if ($response.results.count -eq 0)
    {
        $body = @{
            "name" = $name;
            "department" = $resourcePoolName;
        }
        $jsonBody = ConvertTo-Json -InputObject $body
        $jsonBody = $jsonBody.Replace("\\", "\")
        $response = Invoke-RestMethod -Uri ("http://{0}:{1}/{2}" -f @($computerName, $port, $resourceUri)) -Method Post -Headers $headers -Body $jsonBody -ContentType "application/json" -WebSession $webSession
    }
    else
    {
        # find all applications for one department
        $appnames = @()
        $response1 = Invoke-RestMethod -Uri ("http://{0}:{1}/api/cmdb/applications/application?department__name={2}&page_size=1000" -f @($computerName, $port, $resourcePoolName)) -Method Get -Headers $headers -ContentType "application/json" -WebSession $webSession
        $response1.results | %{ $appnames += $PSItem.name }
        
        $vmnames = @()
        foreach ($appname in $appnames)
        {
            $response1 = Invoke-RestMethod -Uri ("http://{0}:{1}/api/cmdb/devices/virtualmachine?applications={2}&page_size=1000" -f @($computerName, $port, $appname)) -Method Get -Headers $headers -ContentType "application/json" -WebSession $webSession   
            $response1.results | %{ $vmnames += $PSItem.name }
        }

        $body = @{
            "virtual_machines" = $vmnames
        }
        $jsonBody = ConvertTo-Json -InputObject $body
        $jsonBody = $jsonBody.Replace("\\", "\")

        $response = Invoke-RestMethod -Uri $response.results[0].url -Method Patch -Headers $headers -Body $jsonBody -ContentType "application/json" -WebSession $webSession
    }
}