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

# vm data

$body = @{
    "vcenter_server" = "172.16.100.83";
    "vm_template" = "Windows Server 2008 R2 (201512)";
    "host" = "SVR000001";
    "os" = "Windows Server 2008 R2";
    "applications" = @("www.ymatou.com");
    "location" = ConvertTo-Unicode -InputObject "外高桥IDC5";
    "status" = ConvertTo-Unicode -InputObject "正常";
    "name" = "VM01";
}

$jsonBody = ConvertTo-Json -InputObject $body
$jsonBody = $jsonBody.Replace("\\", "\")                    

$resourceUri = "api/cmdb/devices/virtualmachine"
$response = Invoke-RestMethod -Uri ("http://{0}:{1}/{2}?name={3}" -f @($computerName, $port, $resourceUri, "VM01")) -Method Get -Headers $headers -ContentType "application/json" -WebSession $webSession
if ($response.results.count -eq 0)
{
    $response = Invoke-RestMethod -Uri ("http://{0}:{1}/{2}" -f @($computerName, $port, $resourceUri)) -Method Post -Headers $headers -Body $jsonBody -ContentType "application/json" -WebSession $webSession
}
else
{
    $response = Invoke-RestMethod -Uri $response.results[0].url -Method Put -Headers $headers -Body $jsonBody -ContentType "application/json" -WebSession $webSession
}