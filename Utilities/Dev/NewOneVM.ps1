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

function New-RequestBody
{
    param
    (
        [psobject]$InputObject,
        [string[]]$ArrayProperty,
        [hashtable]$FixData,
        [switch]$ForceFixData
    )

    $excludeFields = @("url", "created_date", "modified_date")

    $result = @{}
    $properties = @()

    $tempObject = $InputObject | Select-Object -Property * -ExcludeProperty $excludeFields
    $tempObject | Get-Member -MemberType NoteProperty | %{$properties += $PSItem.Name }
        
    # Remove empty properties
    foreach ($property in $properties)
    {
        # Handling array property
        if ($property -in $ArrayProperty)
        {
            $tempList = @()
            
            if (![string]::IsNullOrEmpty($tempObject.$property))
            {
                $tempObject.$property | %{ $tempList += ConvertTo-Unicode -InputObject $PSItem }
            }

            $result.Add($property, $tempList)
            continue
        }

        if (![string]::IsNullOrEmpty($tempObject.$property))
        {
            $value = ConvertTo-Unicode -InputObject $tempObject.$property
            $result.Add($property, $value.Trim())
        }
    }

    # Fix Data
    if ($FixData.Count -gt 0)
    {
        foreach ($item in $FixData.GetEnumerator())
        {
            $value = ConvertTo-Unicode -InputObject $item.value
            
            # We only need to fix data for some items, which means the '$result' item does not have the key (field name)
            if (!$result.ContainsKey($item.key))
            {
                $result.Add($item.key, $value)
            }
            else
            {
                if ($ForceFixData)
                {
                    $result.Remove($item.key)
                    $result.Add($item.key, $value)
                }
            }
        }
    }

    return $result
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

# get one lb instance
$tempFile = [System.IO.Path]::GetTempFileName()
$response = Invoke-RestMethod -Uri "http://guhuajun:8000/api/cmdb/devices/virtualmachine/594.json" -Method Get -Headers $headers -ContentType "application/json" -WebSession $webSession -OutFile $tempFile
$vm = ConvertFrom-Json -InputObject (Get-Content -Path $tempFile -Encoding UTF8)
Remove-Item -Path $tempFile

# find apps by name
$apps = @()
$appNames = @("userservice.ymatou.com")
foreach ($appName in $appNames)
{
    $response = Invoke-RestMethod -Uri ("http://{0}:{1}/api/cmdb/applications/application?app__name={2}&env__name=Production" -f @($computerName, $port, $appName)) -Method Get -Headers $headers -ContentType "application/json" -WebSession $webSession -OutFile $tempFile
    $response = ConvertFrom-Json -InputObject (Get-Content -Path $tempFile -Encoding UTF8)
    $apps += $response.results[0] | Select-Object -Property *, @{name="owner";expression={ ConvertTo-Unicode -InputObject $PSItem.owner }}, @{name="location";expression={ ConvertTo-Unicode -InputObject $PSItem.location }} -ExcludeProperty "url", "owner", "location"
}

$vm.apps = $apps

# Copy from an existing vm
$vm.name = "{0}_{1}" -f $vm.name, [datetime]::Now.ToString("yyyyMMddhhmmss")

# http://stackoverflow.com/questions/22260343/powershell-convertto-json-missing-nested-level
$body = $vm | Select-Object -Property *, @{name="status";expression={ ConvertTo-Unicode -InputObject $PSItem.status}}, @{name="location";expression={ ConvertTo-Unicode -InputObject $PSItem.location}} -ExcludeProperty "url", "status", "location", "rack", "visible_label"
$jsonBody = ConvertTo-Json -InputObject $body -Depth 3
$jsonBody = $jsonBody.Replace("\\", "\")

$tempFile = [System.IO.Path]::GetTempFileName()
$response = Invoke-RestMethod -Uri "http://guhuajun:8000/api/cmdb/devices/virtualmachine" -Method Post -Body $jsonBody -Headers $headers -ContentType "application/json" -WebSession $webSession -OutFile $tempFile
$response = ConvertFrom-Json -InputObject (Get-Content -Path $tempFile -Encoding UTF8)
$response
Remove-Item -Path $tempFile
