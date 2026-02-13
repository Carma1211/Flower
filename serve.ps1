param(
    [string]$ip = '192.168.1.104',
    [int]$port = 8000
)
$prefix = "http://$($ip):$($port)/"
Add-Type -AssemblyName System.Net.HttpListener
$h = New-Object System.Net.HttpListener
$h.Prefixes.Add($prefix)
try {
    $h.Start()
} catch {
    Write-Error "Failed to start listener: $_"
    exit 1
}
Write-Output "Serving $prefix from $(Get-Location)"
while ($true) {
    $c = $h.GetContext()
    $req = $c.Request
    $path = $req.Url.AbsolutePath.TrimStart('/')
    if ($path -eq '') { $path = 'index.html' }
    $file = Join-Path (Get-Location) $path
    if (Test-Path $file) {
        $bytes = [System.IO.File]::ReadAllBytes($file)
        $c.Response.ContentLength64 = $bytes.Length
        $c.Response.OutputStream.Write($bytes, 0, $bytes.Length)
    } else {
        $c.Response.StatusCode = 404
        $msg = [Text.Encoding]::UTF8.GetBytes('Not found')
        $c.Response.OutputStream.Write($msg, 0, $msg.Length)
    }
    $c.Response.OutputStream.Close()
}
