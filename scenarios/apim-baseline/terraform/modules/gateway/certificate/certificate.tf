##################################################
# Tried creating the certificate using the       #
# azurerm_key_vault_certificate resource, but it #
# doesn't work due to keyvault being private     #
##################################################

# resource "azurerm_key_vault_certificate" "kv_domain_certs" {
#   count        = local.isLocalCertificate ? 1 : 0
#   name         = local.secretName
#   key_vault_id = var.keyvaultId

#   certificate {
#     contents = filebase64(var.certificate_path)
#     password = var.certificate_password
#   }

#   certificate_policy {
#     issuer_parameters {
#       name = "Self"
#     }

#     key_properties {
#       exportable = true
#       key_size   = 256
#       key_type   = "EC"
#       reuse_key  = false
#       curve      = "P-256"
#     }

#     secret_properties {
#       content_type = "application/x-pkcs12"
#     }
#   }

#   lifecycle {
#     prevent_destroy = true
#   }
# }

# resource "azurerm_key_vault_certificate" "local_domain_certs" {
#   count        = !local.isLocalCertificate ? 1 : 0
#   name         = "generated-cert"
#   key_vault_id = var.keyvaultId

#   certificate_policy {
#     issuer_parameters {
#       name = "Self"
#     }

#     key_properties {
#       exportable = true
#       key_size   = 2048
#       key_type   = "RSA"
#       reuse_key  = true
#     }

#     lifetime_action {
#       action {
#         action_type = "AutoRenew"
#       }

#       trigger {
#         days_before_expiry = 30
#       }
#     }

#     secret_properties {
#       content_type = "application/x-pkcs12"
#     }

#     x509_certificate_properties {
#       extended_key_usage = ["1.3.6.1.5.5.7.3.1"]
#       key_usage = [
#         "digitalSignature",
#         "keyEncipherment"
#       ]
#       subject            = "CN=${var.appGatewayFqdn}"
#       validity_in_months = 12
#     }
#   }

#   lifecycle {
#     prevent_destroy = true
#   }
# }


#########################################################
# Tried creating the certificate using the              #
# azurerm_resource_deployment_script_azure_power_shell  #
# resource, but it doesn't work due to keyvault being   #
# private. Main issue compared to bicep is the resource #
# doesn't have the option to run from a subnet          #
#########################################################



# resource "azurerm_resource_deployment_script_azure_power_shell" "appGatewayCertificate" {
#   name                = "${local.secretName}-certificate"
#   resource_group_name = var.sharedResourceGroupName
#   location            = var.location
#   version             = "6.6"
#   retention_interval  = "P1D"
#   command_line        = " -vaultName ${var.keyVaultName} -certificateName ${local.secretName} -subjectName ${local.subjectName} -certPwd ${local.certPwd} -certDataString ${local.certDataString} -certType ${var.appGatewayCertType}"
#   cleanup_preference  = "OnSuccess"
#   force_update_tag    = "1"
#   timeout             = "PT30M"
#   # container -> doesn't have the property to tell it from which subnet to run
#   script_content = <<EOF
#     param(
#       [string] [Parameter(Mandatory=$true)] $vaultName,
#       [string] [Parameter(Mandatory=$true)] $certificateName,
#       [string] [Parameter(Mandatory=$true)] $subjectName,
#       [string] [Parameter(Mandatory=$true)] $certPwd,
#       [string] [Parameter(Mandatory=$true)] $certDataString,
#       [string] [Parameter(Mandatory=$true)] $certType
#       )

#       $ErrorActionPreference = 'Stop'
#       $DeploymentScriptOutputs = @{}
#       if ($certType -eq 'selfsigned') {
#         $policy = New-AzKeyVaultCertificatePolicy -SubjectName $subjectName -IssuerName Self -ValidityInMonths 12 -Verbose

#         # private key is added as a secret that can be retrieved in the ARM template
#         Add-AzKeyVaultCertificate -VaultName $vaultName -Name $certificateName -CertificatePolicy $policy -Verbose

#         $newCert = Get-AzKeyVaultCertificate -VaultName $vaultName -Name $certificateName

#         # it takes a few seconds for KeyVault to finish
#         $tries = 0
#         do {
#           Write-Host 'Waiting for certificate creation completion...'
#           Start-Sleep -Seconds 10
#           $operation = Get-AzKeyVaultCertificateOperation -VaultName $vaultName -Name $certificateName
#           $tries++

#           if ($operation.Status -eq 'failed')
#           {
#           throw 'Creating certificate $certificateName in vault $vaultName failed with error $($operation.ErrorMessage)'
#           }

#           if ($tries -gt 120)
#           {
#           throw 'Timed out waiting for creation of certificate $certificateName in vault $vaultName'
#           }
#         } while ($operation.Status -ne 'completed')
#       }
#       else {
#         $ss = Convertto-SecureString -String $certPwd -AsPlainText -Force;
#         Import-AzKeyVaultCertificate -Name $certificateName -VaultName $vaultName -CertificateString $certDataString -Password $ss
#       }
#   EOF

#   identity {
#     type = "UserAssigned"
#     identity_ids = [
#       data.azurerm_user_assigned_identity.deploymentIdentity.id
#     ]
#   }
#   depends_on = [
#     azurerm_key_vault_access_policy.user_assigned_deployment_keyvault_permissions
#   ]
# }

#########################
# Trying azapi approach #
#########################

# locals
locals {
  secretName     = replace(var.appGatewayFqdn, ".", "-")
  subjectName    = "CN=${var.appGatewayFqdn}"
  certPwd        = var.appGatewayCertType == "selfsigned" ? "null" : var.certificate_password
  certDataString = var.appGatewayCertType == "selfsigned" ? "null" : var.certificate_path
}


# data userasignedidentity for deployment
data "azurerm_user_assigned_identity" "deploymentIdentity" {
  resource_group_name = var.sharedResourceGroupName
  name                = var.deploymentIdentityName
}

resource "azurerm_key_vault_access_policy" "user_assigned_deployment_keyvault_permissions" {
  key_vault_id = var.keyvaultId
  tenant_id    = data.azurerm_user_assigned_identity.deploymentIdentity.tenant_id
  object_id    = data.azurerm_user_assigned_identity.deploymentIdentity.principal_id

  certificate_permissions = [
    "Import",
    "Get",
    "List",
    "Update",
    "Create"
  ]

  secret_permissions = [
    "Get",
    "List",
  ]

  lifecycle {
    prevent_destroy = true
  }
}


# get the ide of the resource group
data "azurerm_resource_group" "sharedResourceGroup" {
  name = var.sharedResourceGroupName
}


resource "azapi_resource" "appGatewayCertificate" {
  type       = "Microsoft.Resources/deploymentScripts@2023-08-01"
  name       = "${local.secretName}-certificate"
  depends_on = [azurerm_key_vault_access_policy.user_assigned_deployment_keyvault_permissions]
  parent_id  = data.azurerm_resource_group.sharedResourceGroup.id
  identity {
    type         = "UserAssigned"
    identity_ids = [data.azurerm_user_assigned_identity.deploymentIdentity.id]
  }

  body = jsonencode({
    kind     = "AzurePowerShell"
    location = var.location

    properties = {
      storageAccountSettings = {
        storageAccountName = var.deploymentStorageName
      }
      azPowerShellVersion = "6.6"
      containerSettings = {
        subnetIds = [
          {
            id = var.deploymentSubnetId
          }
        ]
      }
      arguments         = " -vaultName ${var.keyVaultName} -certificateName ${local.secretName} -subjectName ${local.subjectName} -certPwd ${local.certPwd} -certDataString ${local.certDataString} -certType ${var.appGatewayCertType}"
      scriptContent     = <<-EOT
        param(
        [string] [Parameter(Mandatory=$true)] $vaultName,
        [string] [Parameter(Mandatory=$true)] $certificateName,
        [string] [Parameter(Mandatory=$true)] $subjectName,
        [string] [Parameter(Mandatory=$true)] $certPwd,
        [string] [Parameter(Mandatory=$true)] $certDataString,
        [string] [Parameter(Mandatory=$true)] $certType
        )

        $ErrorActionPreference = 'Stop'
        $DeploymentScriptOutputs = @{}
        if ($certType -eq 'selfsigned') {
          $policy = New-AzKeyVaultCertificatePolicy -SubjectName $subjectName -IssuerName Self -ValidityInMonths 12 -Verbose

          # private key is added as a secret that can be retrieved in the ARM template
          Add-AzKeyVaultCertificate -VaultName $vaultName -Name $certificateName -CertificatePolicy $policy -Verbose

          $newCert = Get-AzKeyVaultCertificate -VaultName $vaultName -Name $certificateName

          # it takes a few seconds for KeyVault to finish
          $tries = 0
          do {
            Write-Host 'Waiting for certificate creation completion...'
            Start-Sleep -Seconds 10
            $operation = Get-AzKeyVaultCertificateOperation -VaultName $vaultName -Name $certificateName
            $tries++

            if ($operation.Status -eq 'failed')
            {
            throw 'Creating certificate $certificateName in vault $vaultName failed with error $($operation.ErrorMessage)'
            }

            if ($tries -gt 120)
            {
            throw 'Timed out waiting for creation of certificate $certificateName in vault $vaultName'
            }
          } while ($operation.Status -ne 'completed')
        }
        else {
          $ss = Convertto-SecureString -String $certPwd -AsPlainText -Force;
          Import-AzKeyVaultCertificate -Name $certificateName -VaultName $vaultName -CertificateString $certDataString -Password $ss
        }
        $certificateIdOutput = $(Get-AzKeyVaultCertificate -VaultName $vaultName -Name $certificateName).id
        Write-Output "certificateId: $certificateIdOutput"
        $DeploymentScriptOutputs = @{}
        $DeploymentScriptOutputs['certificateId'] = $certificateIdOutput
      EOT
      retentionInterval = "P1D"
    }
  })
  response_export_values = ["*"]
}

output "secret_id" {
  value = jsondecode(azapi_resource.appGatewayCertificate.output).properties.outputs.certificateId
}
