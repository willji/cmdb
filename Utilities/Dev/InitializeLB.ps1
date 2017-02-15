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

    for ($i = 0; $i -lt $Data.Count; $i+=$Concurrent)
    { 
        $startIndex = $i
        foreach -parallel ($item in (1..$Concurrent))
        {
            $itemIndex = $startIndex + $item
            if ($itemIndex -le $Data.Count)
            {
                $vm = $Data[$itemIndex]

                $tempFile = [System.IO.Path]::GetTempFileName()

                # get host
                $response = Invoke-RestMethod -Uri ("http://{0}:{1}/api/cmdb/devices/physicalserver?ipaddresses={2}" -f @($ComputerName, $Port, $vm.host)) -Method Get -Headers $Headers -ContentType "application/json" -WebSession $WebSession -OutFile $tempFile
                $response = ConvertFrom-Json -InputObject (Get-Content -Path $tempFile -Encoding UTF8)
                
                if ($response.results.count -eq 0)
                {
                    Write-Output -InputObject ("{0} does not exist." -f $vm.host)
                }
                else
                {
                    $hostName = $response.results[0].name

                    # prepare request body
                    $vmIPs = @()
                    if (![string]::IsNullOrEmpty($vm.ip)) { $vmIPs += $vm.ip }

                    $vmName = $vm.vmname

                    $body = inlinescript {

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

                        $vmIP = $using:vm.ip

                        $body = @{
                            "vcenter_server" = "172.16.100.83";
                            "vm_template" = "Windows Server 2008 R2 (201512)";
                            # using host asset info
                            "asset" = $using:hostName;
                            "os" = "CentOS 6.5";
                            "ipaddresses" = $using:vmIPs;
                            "location" = if ($vmip.StartsWith('10.10')) { ConvertTo-Unicode -InputObject "外高桥IDC5" } else { ConvertTo-Unicode -InputObject "外高桥IDC6" };
                            "type" = if ($using:vmName -match "nginx") { "nginx" } else { "haproxy" };
                            "status" = ConvertTo-Unicode -InputObject "正常";
                            "name" = ConvertTo-Unicode -InputObject $using:vmName;
                        }

                        return $body
                    }
    
                    $jsonBody = ConvertTo-Json -InputObject $body
                    $jsonBody = $jsonBody.Replace("\\", "\")                    

                    $resourceUri = "api/cmdb/devices/loadbalancer"
                    $response = Invoke-RestMethod -Uri ("http://{0}:{1}/{2}?name={3}" -f @($computerName, $port, $resourceUri, $vmName)) -Method Get -Headers $headers -ContentType "application/json" -WebSession $webSession
                    if ($response.results.count -eq 0)
                    {
                        $response = Invoke-RestMethod -Uri ("http://{0}:{1}/{2}" -f @($computerName, $port, $resourceUri)) -Method Post -Headers $headers -Body $jsonBody -ContentType "application/json" -WebSession $webSession
                    }
                    else
                    {
                        $response = Invoke-RestMethod -Uri $response.results[0].url -Method Put -Headers $headers -Body $jsonBody -ContentType "application/json" -WebSession $webSession
                    }
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
$vms1 = Import-Csv -Path D:\CorpDocs\assets\vms.csv -Encoding UTF8
$vms2 = Import-Csv -Path D:\CorpDocs\assets\vms-6.csv -Encoding UTF8
$vms = $vms1 + $vms2
$vms  = $vms | ?{ $PSItem.vmname -match "nginx|ha|haproxy" }
$vms  = $vms | ?{ $PSItem.vmname -notmatch "authapp|handler|beihai" }

Send-Data -Data $vms -Concurrent 10 -ComputerName $computerName -Port $port -Headers $headers -WebSession $webSession