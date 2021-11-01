param (
    [Parameter(Mandatory=$true)]
    [string] $AppGatewayDomain,

    [Parameter(Mandatory=$true)]
    [string] $KeyVaultName,

    [Parameter(Mandatory=$true)]
    [ValidateScript({Test-Path -Path $_})]
    [string] $CertPath,

    [Parameter(Mandatory=$true)]
    [securestring] $CertPassword

)

$opts = @{
    Name          = $AppGatewayDomain.Replace('.','-')
    VaultName     = $KeyVaultName
    FilePath      = $CertPath
    Password      = $CertPassword
}
Import-AzKeyVaultCertificate @opts -Verbose