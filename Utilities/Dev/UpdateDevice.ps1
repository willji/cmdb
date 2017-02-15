#region helper functions

workflow Send-Data
{
    param
    (
        [psobject[]]$Data,
        [int]$Concurrent = 2,
        [string]$ComputerName,
        [string]$Port,
        [hashtable]$Headers,
        [psobject]$WebSession
    )

    $devices = inlinescript {
        $devices = @{}
        foreach ($server in $using:Data)
        {
            $devices.Add($server.ip, @{"cpu" = $server.cpu; "memory" = $server.memory; "hdd" = $server.hdd})
        }
        return $devices
    }

    for ($i = 0; $i -lt $Data.Count; $i+=$Concurrent)
    { 
        $startIndex = $i
        foreach -parallel ($item in (1..$Concurrent))
        {
            $itemIndex = $startIndex + $item
            if ($itemIndex -le $Data.Count)
            {
                $device = $Data[$itemIndex]

                $tempFile = [System.IO.Path]::GetTempFileName()

                # get host
                # $response = Invoke-RestMethod -Uri ("http://{0}:{1}/api/cmdb/devices/physicalserver?ipaddresses={2}" -f @($ComputerName, $Port, $device.ip)) -Method Get -Headers $Headers -ContentType "application/json" -WebSession $WebSession -OutFile $tempFile
                $response = Invoke-RestMethod -Uri ("http://{0}:{1}/api/cmdb/devices/virtualmachine?name={2}" -f @($ComputerName, $Port, $device.ip)) -Method Get -Headers $Headers -ContentType "application/json" -WebSession $WebSession -OutFile $tempFile
                $response = ConvertFrom-Json -InputObject (Get-Content -Path $tempFile -Encoding UTF8)
                
                if ($response.results.count -eq 0)
                {
                    Write-Output -InputObject ("{0} does not exist." -f $device.ip)
                }
                else
                {
                    $deviceName = $response.results[0].name

                    $body = @{
                        "virtual_cpu" = $device.cpu;
                        "virtual_memory" = $device.memory;
                        "virtual_storage" = $device.hdd;
                    }
    
                    $jsonBody = ConvertTo-Json -InputObject $body
                    $jsonBody = $jsonBody.Replace("\\", "\")                    

                    $response = Invoke-RestMethod -Uri $response.results[0].url -Method Patch -Headers $Headers -Body $jsonBody -ContentType "application/json" -WebSession $WebSession
                }

                Remove-Item -Path $tempFile
            }
        }
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

# vm data
# $servers = Import-Csv -Path D:\CorpDocs\assets\host_CPUMEMHDD.csv
$servers = Import-Csv -Path D:\CorpDocs\assets\vm_CPUMEMHDD.csv

Send-Data -Data $servers -Concurrent 10 -ComputerName $computerName -Port $port -Headers $headers -WebSession $webSession