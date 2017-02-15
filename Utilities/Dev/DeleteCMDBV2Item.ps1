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

function Get-CsrfToken
{
    param
    (
        [string]$Uri,
        [string]$Username,
        [string]$Password
    )

    $webResponse = Invoke-WebRequest -Uri $Uri -SessionVariable script:webSession3
    $csrfToken   = $webResponse.BaseResponse.Cookies['csrftoken'].Value

    # Prepare authentication
    $body = @{
        "csrfmiddlewaretoken" = $csrfToken;
        "username"            = $UserName;
        "password"            = $Password;
        "next"                = '/'
        'submit'              = 'Log in'
    }

    # Turn off auto redirection to get seesionid, this requires you user name and password is correct. Otherwise you will get a HTTP 200 (Loogin failed).
    $webResponse = Invoke-WebRequest -Uri $Uri -Method Post -Body $body -WebSession $webSession3 -MaximumRedirection 0 -ErrorAction Ignore

    # Get new token and sessionid
    return $webResponse.BaseResponse.Cookies['csrftoken'].Value
}

#endregion

# Main entry

# Script variables
$script:webSession2    = $null
$script:cmdbv2RootUri  = "http://guhuajun:8000"
$script:cmdbv2LoginApi = "{0}/api/cmdb/token/" -f $cmdbv2RootUri
$script:cmdbv2Token    = $null
$script:header2        = $null

#region Get Tokens

try
{
    # Prepare authentication
    $body = @{
        "username" = "opsadmin";
        "password" = "Welcome123";
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

$results = Get-AllResult -Response (Invoke-RestMethod -Uri "http://guhuajun:8000/api/cmdb/devices/loadbalancer" -Method Get -Headers $header2 -WebSession $webSession2) -Header $header2 -WebSession $webSession2
foreach($result in $results)
{
    $reseponse = Invoke-RestMethod -Uri $result.url -Method Delete -Headers $header2 -WebSession $webSession2
}