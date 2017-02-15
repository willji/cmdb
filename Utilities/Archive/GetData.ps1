$webSession = $null

$userName = "opsadmin"
$password = "Welcome123"
$loginURI = "http://guhuajun:8000/api/api-auth/login/"

# Get token
$webResponse = Invoke-WebRequest -Uri $loginURI -SessionVariable webSession
$csrfToken   = $webResponse.BaseResponse.Cookies['csrftoken'].Value

# Prepare authentication
$body = @{
    "csrfmiddlewaretoken" = $csrfToken;
    "username"            = $userName;
    "password"            = $password;
    "next"                = '/'
    'submit'              = 'Log in'
}

# Turn off auto redirection to get seesionid, this requires you user name and password is correct. Otherwise you will get a HTTP 200 (Loogin failed).
$webResponse = Invoke-WebRequest -Uri $loginURI -Method Post -Body $body -WebSession $webSession -MaximumRedirection 0 -ErrorAction Ignore

# Get new token and sessionid
$csrfToken = $webResponse.BaseResponse.Cookies['csrftoken'].Value
$sessionid = $webResponse.BaseResponse.Cookies['sessionid'].Value

$body = @{
    "csrfmiddlewaretoken" = $csrfToken;
    "sessionid"           = $sessionid;
}


$webResponse = Invoke-RestMethod -Uri "http://guhuajun:8000/networks/ipv4adresses/?ip='192.168.20.1'" -Method Get -Body $body -WebSession $webSession
$webResponse.results
# Invoke-RestMethod -Uri "http://guhuajun:8000/devices/physicalservers/1/" -Method Get -Body $body -WebSession $webSession