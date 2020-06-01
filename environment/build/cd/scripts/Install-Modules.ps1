Copy-Item -Path "C:\temp\Sitecore JavaScript Services Server for Sitecore 9.3 XP 13.0.0 rev. 190924 CD\*" -Destination "C:\inetpub\wwwroot" -Recurse -ErrorAction SilentlyContinue -ErrorVariable capturedErrors
$capturedErrors | ForEach-Object {
    if ($_ -notmatch "already exists") { throw $_ }
}
