$nginxServers = @{
    "NGINX-13.27-img" = "10.10.13.27"
    "NGINX-22.151" = "10.11.22.151"
    "NGINX-22.152" = "10.11.22.152"
    "NGINX-22.153" = "10.11.22.153"
    "NGINX-22.154" = "10.11.22.154"
    "NGINX-22.155" = "10.11.22.155"
    "NGINX-22.156" = "10.11.22.156"
    "Nginx-10.11.31.151-PC" = "10.11.31.151"
    "Nginx-10.11.32.152-pc" = "10.11.32.152"
    "Nginx-10.11.33.153-pc" = "10.11.33.153"
    "Nginx-10.11.31.152-APP/GZIP" = "10.11.31.152"
    "Nginx-10.11.31.153-APP/GZIP" = "10.11.31.153"
    "Nginx-10.11.32.151-APP/GZIP" = "10.11.32.151"
    "Nginx-10.11.32.153-APP/GZIP" = "10.11.32.153"
    "Nginx-10.11.31.154-JYH" = "10.11.31.154"
    "Nginx-10.11.32.155-JYH" = "10.11.32.155"
    "Nginx-10.11.33.151-JYH" = "10.11.33.151"
    "Nginx-10.11.34.151-JYH" = "10.11.34.151"
    "Nginx-10.11.34.152-JYH" = "10.11.34.152"
    "Nginx-10.11.32.154-XLOBO/SELLER" = "10.11.32.154"
    "Nginx-10.11.33.152-XLOBO/SELLER" = "10.11.33.152"
    "Nginx-10.11.31.155-STATIC" = "10.11.31.155"
    "Nginx-10.11.33.159-STATIC" = "10.11.33.159"
    "Nginx-10.11.31.157-Lan" = "10.11.31.157"
    "Nginx-10.11.32.158-Lan" = "10.11.32.158"
    "Nginx-10.11.33.155-Lan" = "10.11.33.155"
}

$results = @()
foreach ($nginxServer in $nginxServers.GetEnumerator())
{
    if (!(Test-Connection -ComputerName $nginxServer.Value -Count 1 -Quiet)) { continue }
    $url = "http://{0}:808/check-stats?format=json" -f $nginxServer.Value
    $response = Invoke-RestMethod -Uri $url -Method Get -ContentType "application/json"
    $response.servers.server | ?{$PSItem.status -eq "up"} | Select-Object -Property upstream -Unique | %{ 
        $app = $PSItem.upstream.replace("_", ".")
        if (!$app.EndsWith(".com")) { $app = $app.Insert($app.Length, ".com") }
        $result = [PSCustomObject]@{
            "server" = $nginxServer.Value;
            "app"    = $app;
        }
        $results += $result
    }
}

$results | Export-Csv -Path D:\CorpDocs\nginx_upstreams.csv -NoTypeInformation -Encoding UTF8