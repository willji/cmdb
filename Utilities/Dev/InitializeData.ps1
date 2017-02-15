#region helper functions

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

#region Contacts

# contact
$name = "guhuajun"
$body = @{
    "name"   = $name;
    "email"  = "guhuajun@ymatou.com";
    "mobile" = "18616702062";
}
$jsonBody = ConvertTo-Json -InputObject $body
$response = Invoke-RestMethod -Uri ("http://{0}:{1}/api/cmdb/contacts/contact?name=$name" -f @($computerName, $port)) -Method Get -Headers $headers -ContentType "application/json" -WebSession $webSession
if ($response.results.count -eq 0)
{
    $response = Invoke-RestMethod -Uri ("http://{0}:{1}/api/cmdb/contacts/contact" -f @($computerName, $port)) -Method Post -Headers $headers -Body $jsonBody -ContentType "application/json" -WebSession $webSession
    $response
}

#endregion

#region Departments

# department
$name = "ops"
$body = @{
    "name"   = $name;
}
$jsonBody = ConvertTo-Json -InputObject $body
$response = Invoke-RestMethod -Uri ("http://{0}:{1}/api/cmdb/departments/department?name=$name" -f @($computerName, $port)) -Method Get -Headers $headers -ContentType "application/json" -WebSession $webSession
if ($response.results.count -eq 0)
{
    $response = Invoke-RestMethod -Uri ("http://{0}:{1}/api/cmdb/departments/department" -f @($computerName, $port)) -Method Post -Headers $headers -Body $jsonBody -ContentType "application/json" -WebSession $webSession
    $response
}

#endregion

#region Environments

# environment
$name = "PROD"
$body = @{
    "name"   = $name;
}
$jsonBody = ConvertTo-Json -InputObject $body
$response = Invoke-RestMethod -Uri ("http://{0}:{1}/api/cmdb/environments/environment?name=$name" -f @($computerName, $port)) -Method Get -Headers $headers -ContentType "application/json" -WebSession $webSession
if ($response.results.count -eq 0)
{
    $response = Invoke-RestMethod -Uri ("http://{0}:{1}/api/cmdb/environments/environment" -f @($computerName, $port)) -Method Post -Headers $headers -Body $jsonBody -ContentType "application/json" -WebSession $webSession
    $response
}

# location
$name = "SHA_PD_WGJ"
$body = @{
    "name"   = $name;
}
$jsonBody = ConvertTo-Json -InputObject $body
$response = Invoke-RestMethod -Uri ("http://{0}:{1}/api/cmdb/environments/location?name=$name" -f @($computerName, $port)) -Method Get -Headers $headers -ContentType "application/json" -WebSession $webSession
if ($response.results.count -eq 0)
{
    $response = Invoke-RestMethod -Uri ("http://{0}:{1}/api/cmdb/environments/location" -f @($computerName, $port)) -Method Post -Headers $headers -Body $jsonBody -ContentType "application/json" -WebSession $webSession
    $response
}

#endregion

#region Assets

# Asset Specification
$name = "HP Proliant DL380 G5"
$body = @{
    "name" = $name;
}
$jsonBody = ConvertTo-Json -InputObject $body
$response = Invoke-RestMethod -Uri ("http://{0}:{1}/api/cmdb/assets/assetspcification?name=$name" -f @($computerName, $port)) -Method Get -Headers $headers -ContentType "application/json" -WebSession $webSession
if ($response.results.count -eq 0)
{
    $response = Invoke-RestMethod -Uri ("http://{0}:{1}/api/cmdb/assets/assetspcification" -f @($computerName, $port)) -Method Post -Headers $headers -Body $jsonBody -ContentType "application/json" -WebSession $webSession
    $response
}

# Asset Status
$name = "已部署"
$body = @{
    "name" = ConvertTo-Unicode -InputObject $name;
}
$jsonBody = ConvertTo-Json -InputObject $body
$jsonBody = $jsonBody.Replace("\\", "\")
$response = Invoke-RestMethod -Uri ("http://{0}:{1}/api/cmdb/assets/assetstatus?name={2}" -f @($computerName, $port, $name)) -Method Get -Headers $headers -ContentType "application/json" -WebSession $webSession
if ($response.results.count -eq 0)
{
    $response = Invoke-RestMethod -Uri ("http://{0}:{1}/api/cmdb/assets/assetstatus" -f @($computerName, $port)) -Method Post -Headers $headers -Body $jsonBody -ContentType "application/json" -WebSession $webSession
    $response
}

# Asset Type
$name = "机架式服务器"
$body = @{
    "name" = ConvertTo-Unicode -InputObject $name;
}
$jsonBody = ConvertTo-Json -InputObject $body
$jsonBody = $jsonBody.Replace("\\", "\")
$response = Invoke-RestMethod -Uri ("http://{0}:{1}/api/cmdb/assets/assettype?name=$name" -f @($computerName, $port)) -Method Get -Headers $headers -ContentType "application/json" -WebSession $webSession
if ($response.results.count -eq 0)
{
    $response = Invoke-RestMethod -Uri ("http://{0}:{1}/api/cmdb/assets/assettype" -f @($computerName, $port)) -Method Post -Headers $headers -Body $jsonBody -ContentType "application/json" -WebSession $webSession
    $response
}

# Asset

$name = "SERVER001"
$body = @{
    "name" = $name;
    "asset_tag" = $name;
    "type" = ConvertTo-Unicode -InputObject "机架式服务器";
    "status" = ConvertTo-Unicode -InputObject "已部署";
    "specification" = "HP Proliant DL380 G5";
    "owner" = "guhuajun";
    "dc_contact" = @("guhuajun");
    "vendor_contact" = @("guhuajun");
    "department" = "ops";
}
$jsonBody = ConvertTo-Json -InputObject $body
$jsonBody = $jsonBody.Replace("\\", "\")
$response = Invoke-RestMethod -Uri ("http://{0}:{1}/api/cmdb/assets/asset?name=$name" -f @($computerName, $port)) -Method Get -Headers $headers -ContentType "application/json" -WebSession $webSession
if ($response.results.count -eq 0)
{
    $response = Invoke-RestMethod -Uri ("http://{0}:{1}/api/cmdb/assets/asset" -f @($computerName, $port)) -Method Post -Headers $headers -Body $jsonBody -ContentType "application/json" -WebSession $webSession
    $response
}

#endregion

#region VMWare

# vcenter server

$name = "172.16.100.83"
$body = @{
    "name"   = $name;
}
$jsonBody = ConvertTo-Json -InputObject $body
$response = Invoke-RestMethod -Uri ("http://{0}:{1}/api/cmdb/vmware/vcenterserver?name=$name" -f @($computerName, $port)) -Method Get -Headers $headers -ContentType "application/json" -WebSession $webSession
if ($response.results.count -eq 0)
{
    $response = Invoke-RestMethod -Uri ("http://{0}:{1}/api/cmdb/vmware/vcenterserver" -f @($computerName, $port)) -Method Post -Headers $headers -Body $jsonBody -ContentType "application/json" -WebSession $webSession
    $response
}

$name = "Windows Server 2008 R2 (201512)"
$body = @{
    "name"   = $name;
}
$jsonBody = ConvertTo-Json -InputObject $body
$response = Invoke-RestMethod -Uri ("http://{0}:{1}/api/cmdb/vmware/vmtemplate?name=$name" -f @($computerName, $port)) -Method Get -Headers $headers -ContentType "application/json" -WebSession $webSession
if ($response.results.count -eq 0)
{
    $response = Invoke-RestMethod -Uri ("http://{0}:{1}/api/cmdb/vmware/vmtemplate" -f @($computerName, $port)) -Method Post -Headers $headers -Body $jsonBody -ContentType "application/json" -WebSession $webSession
    $response
}

#endregion

#region Applications

# warmup url
$warmupUrl = "http://www.ymatou.com/"
$body = @{
    "warmup_url"       = $warmupUrl;
    "sequence_number" = "1";
    "expected_status" = "200";
}
$jsonBody = ConvertTo-Json -InputObject $body
$response = Invoke-RestMethod -Uri ("http://{0}:{1}/api/cmdb/applications/warmupurl?warmup_url=$warmupUrl" -f @($computerName, $port)) -Method Get -Headers $headers -ContentType "application/json" -WebSession $webSession
if ($response.results.count -eq 0)
{
    $response = Invoke-RestMethod -Uri ("http://{0}:{1}/api/cmdb/applications/warmupurl" -f @($computerName, $port)) -Method Post -Headers $headers -Body $jsonBody -ContentType "application/json" -WebSession $webSession
    $response
}

# application name
$name = "www.ymatou.com"
$body = @{
    "name"       = $name;
    "department" = "ops";
}
$jsonBody = ConvertTo-Json -InputObject $body
$response = Invoke-RestMethod -Uri ("http://{0}:{1}/api/cmdb/applications/applicationname?name=$name" -f @($computerName, $port)) -Method Get -Headers $headers -ContentType "application/json" -WebSession $webSession
if ($response.results.count -eq 0)
{
    $response = Invoke-RestMethod -Uri ("http://{0}:{1}/api/cmdb/applications/applicationname" -f @($computerName, $port)) -Method Post -Headers $headers -Body $jsonBody -ContentType "application/json" -WebSession $webSession
    $response
}

# application

$name = "www.ymatou.com"
$environment = "PROD"
$body = @{
    "app"   = $name;
    "owner" = "guhuajun";
    "environment" = $environment;
    "warmup_urls" = @();
    "ipaddresses" = @();
}
$jsonBody = ConvertTo-Json -InputObject $body
$response = Invoke-RestMethod -Uri ("http://{0}:{1}/api/cmdb/applications/application?app__name=$name&environment__name=$environment" -f @($computerName, $port)) -Method Get -Headers $headers -ContentType "application/json" -WebSession $webSession
if ($response.results.count -eq 0)
{
    $response = Invoke-RestMethod -Uri ("http://{0}:{1}/api/cmdb/applications/application" -f @($computerName, $port)) -Method Post -Headers $headers -Body $jsonBody -ContentType "application/json" -WebSession $webSession
    $response
}

#endregion

#region Devices

# os type
$name = "Windows Server 2008 R2"
$body = @{
    "name" = $name;
}
$jsonBody = ConvertTo-Json -InputObject $body
$response = Invoke-RestMethod -Uri ("http://{0}:{1}/api/cmdb/devices/ostype?name=$name" -f @($computerName, $port)) -Method Get -Headers $headers -ContentType "application/json" -WebSession $webSession
if ($response.results.count -eq 0)
{
    $response = Invoke-RestMethod -Uri ("http://{0}:{1}/api/cmdb/devices/ostype" -f @($computerName, $port)) -Method Post -Headers $headers -Body $jsonBody -ContentType "application/json" -WebSession $webSession
    $response
}

# device status
$name = "Online"
$body = @{
    "name" = $name;
}
$jsonBody = ConvertTo-Json -InputObject $body
$response = Invoke-RestMethod -Uri ("http://{0}:{1}/api/cmdb/devices/devicestatus?name=$name" -f @($computerName, $port)) -Method Get -Headers $headers -ContentType "application/json" -WebSession $webSession
if ($response.results.count -eq 0)
{
    $response = Invoke-RestMethod -Uri ("http://{0}:{1}/api/cmdb/devices/devicestatus" -f @($computerName, $port)) -Method Post -Headers $headers -Body $jsonBody -ContentType "application/json" -WebSession $webSession
    $response
}

# physical server
$name = "SERVER001"
$body = @{
    "asset" = "SERVER001";
    "status" = "Online";
    "location" = "SHA_PD_WGJ"
    "ipaddresses" = @();
    "os_type" = "Windows Server 2008 R2";
    "server_specification" = "HP Proliant DL380 G5"
    "name" = "SERVER001";
    "rack" = "D12";
    "unit_position" = "U12";
    "unit_height" = "2";
    "cpu" = "24";
    "memory" = 16GB;
    "storage_capacity" = 1TB;
    "visible_label" = "SERVER001";
    "raid_type" = "RAID01"
}
$jsonBody = ConvertTo-Json -InputObject $body
$response = Invoke-RestMethod -Uri ("http://{0}:{1}/api/cmdb/devices/physicalserver?name=$name" -f @($computerName, $port)) -Method Get -Headers $headers -ContentType "application/json" -WebSession $webSession
if ($response.results.count -eq 0)
{
    $response = Invoke-RestMethod -Uri ("http://{0}:{1}/api/cmdb/devices/physicalserver" -f @($computerName, $port)) -Method Post -Headers $headers -Body $jsonBody -ContentType "application/json" -WebSession $webSession
    $response
}

# virtual machine
$name = "WEB-101125110"
$body = @{
    "host" = "SERVER001";
    "os" = "Windows Server 2008 R2";
    "ipaddresses" = @();
    "apps" = @("www.ymatou.com");
    "status" = "Online";
    "name" = $name;
    "virtual_cpu" = 2;
    "virtual_memory" = 16GB;
    "virtual_storage" = 120GB;
    "vcenter_server" = "172.16.100.83";
    "vm_template" = "Windows Server 2008 R2 (201512)";
}
$jsonBody = ConvertTo-Json -InputObject $body
$response = Invoke-RestMethod -Uri ("http://{0}:{1}/api/cmdb/devices/virtualmachine?name=$name" -f @($computerName, $port)) -Method Get -Headers $headers -ContentType "application/json" -WebSession $webSession
if ($response.results.count -eq 0)
{
    $response = Invoke-RestMethod -Uri ("http://{0}:{1}/api/cmdb/devices/virtualmachine" -f @($computerName, $port)) -Method Post -Headers $headers -Body $jsonBody -ContentType "application/json" -WebSession $webSession
    $response
}

#endregion

#region Resource Pools

# resource pool

$name = "OPS Pool"
$body = @{
    "name"   = $name;
    "virtual_machines" = @("WEB-101125110");
    "department" = "ops";
}
$jsonBody = ConvertTo-Json -InputObject $body
$response = Invoke-RestMethod -Uri ("http://{0}:{1}/api/cmdb/resourcepools/resourcepool?name=$name" -f @($computerName, $port)) -Method Get -Headers $headers -ContentType "application/json" -WebSession $webSession
if ($response.results.count -eq 0)
{
    $response = Invoke-RestMethod -Uri ("http://{0}:{1}/api/cmdb/resourcepools/resourcepool" -f @($computerName, $port)) -Method Post -Headers $headers -Body $jsonBody -ContentType "application/json" -WebSession $webSession
    $response
}

#endregion