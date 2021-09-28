param(
    [Parameter(Mandatory=$true)]
    [ValidateScript({Test-Path -Path $_})]
    [string] $CertPath
)
return [convert]::ToBase64String( (Get-Content -AsByteStream -Path $CertPath) )