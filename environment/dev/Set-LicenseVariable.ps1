$licensePath = [System.Environment]::GetEnvironmentVariable("SITECORE_LICENSE_PATH", "User")
if ([string]::IsNullOrEmpty($licensePath)){
    throw "SITECORE_LICENSE_PATH environment variable is not set."
}

$licenseFileStream = [System.IO.File]::OpenRead($licensePath);
$licenseString = $null

try
{
    $memory = [System.IO.MemoryStream]::new()

    $gzip = [System.IO.Compression.GZipStream]::new($memory, [System.IO.Compression.CompressionLevel]::Optimal, $false);
    $licenseFileStream.CopyTo($gzip);
    $gzip.Close();

    # Base64 encode the gzipped content
    $licenseString = [System.Convert]::ToBase64String($memory.ToArray())
}
finally
{
    # Cleanup
    if ($null -ne $gzip)
    {
        $gzip.Dispose()
        $gzip = $null
    }

    if ($null -ne $memory)
    {
        $memory.Dispose()
        $memory = $null
    }

    $licenseFileStream = $null
}

# Sanity check
if ($licenseString.Length -le 100)
{
    throw "Unknown error, the gzipped and base64 encoded string '$licenseString' is too short."
}

# Persist in current session
$env:SITECORE_LICENSE = $licenseString
Write-Host "SITECORE_LICENSE context variable set." -fore Green
