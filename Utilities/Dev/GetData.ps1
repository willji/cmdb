$OutputEncoding = [System.Text.UTF8Encoding]::UTF8

#region Utility functions

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

# Main entry

# Script variables
$script:webSession2    = $null
$script:cmdbv2RootUri  = "http://cmdb_v2.ops.ymatou.cn"
$script:cmdbv2LoginApi = "{0}/api/cmdb/token/" -f $cmdbv2RootUri
$script:cmdbv2Token    = $null
$script:header2        = $null

#region Get Tokens

try
{
    # Prepare authentication
    $body = @{
        "username" = "opsadmin";
        "password" = "cmdb@ymt8102";
    }

    $jsonBody = ConvertTo-Json -InputObject $body
    $response = Invoke-RestMethod -Uri $cmdbv2LoginApi -Method Post -Body $jsonBody -ContentType "application/json" -WebSession $webSession2
    $cmdbv2Token = $response.token

    # Prepare authentication header

    $header2 = @{
        "Authorization" = "Token $cmdbv2Token";
    }
}
catch
{
    throw $PSItem
}

#endregion

$results = @()
$response = Get-AllResult -Response (Invoke-RestMethod -Uri "http://cmdb_v2.ops.ymatou.cn/api/cmdb/applications/application" -Method Get -Headers $header2 -WebSession $webSession2) -Header $header2 -WebSession $webSession2

foreach ($result in $response)
{
    foreach ($appgroup in $result.app_groups)
    {
        $ips = @()
        $appgroup.Production_1 | %{$ips += $PSItem}
    }

    foreach ($ip in $ips)
    {
        $results += [PSCustomObject]@{
            "ip"          = $ip
            "application" = $result.name;
            "department"  = $result.department;
            "os"          = if ($result.type -match 'iis|service') { "Windows" } else { 'Linux' };
        }
    }
}

$results | Select-Object -Property * | Export-Csv -Path d:\temp\application_department_ips.csv -NoTypeInformation