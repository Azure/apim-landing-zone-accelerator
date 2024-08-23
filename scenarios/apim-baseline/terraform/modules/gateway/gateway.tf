locals {
  appGatewayName        = "appgw-${var.resourceSuffix}"
  appGatewayPrimaryPip  = "pip-appgw-${var.resourceSuffix}"
  appGatewayIdentityId  = "identity-${local.appGatewayName}"
  httpsBackendProbeName = "APIM"
  isLocalCertificate    = var.appGatewayCertType == "custom"
  # certificateSecretId   = local.isLocalCertificate ? azurerm_key_vault_certificate.kv_domain_certs[0].secret_id : azurerm_key_vault_certificate.local_domain_certs[0].secret_id
  secretName     = replace(var.appGatewayFqdn, ".", "-")
  subjectName    = "CN=${var.appGatewayFqdn}"
  certPwd        = var.appGatewayCertType == "selfsigned" ? "null" : var.certificate_password
  certDataString = var.appGatewayCertType == "selfsigned" ? "null" : var.certificate_path
}



resource "azurerm_user_assigned_identity" "user_assigned_identity" {
  resource_group_name = var.resourceGroupName
  location            = var.location

  name = local.appGatewayIdentityId

  lifecycle {
    prevent_destroy = true
  }
}

resource "azurerm_key_vault_access_policy" "user_assigned_identity_keyvault_permissions" {
  key_vault_id = var.keyvaultId
  tenant_id    = azurerm_user_assigned_identity.user_assigned_identity.tenant_id
  object_id    = azurerm_user_assigned_identity.user_assigned_identity.principal_id

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

module "certificate" {
  source                  = "./certificate"
  location                = var.location
  sharedResourceGroupName = var.sharedResourceGroupName
  keyVaultName            = var.keyVaultName
  deploymentIdentityName  = var.deploymentIdentityName
  keyvaultId              = var.keyvaultId
  appGatewayFqdn          = var.appGatewayFqdn
  certificate_path        = var.certificate_path
  certificate_password    = var.certificate_password
  appGatewayCertType      = var.appGatewayCertType
  deploymentSubnetId      = var.deploymentSubnetId
  deploymentStorageName   = var.deploymentStorageName
}

//Public IP
resource "azurerm_public_ip" "public_ip" {
  name                = local.appGatewayPrimaryPip
  resource_group_name = var.resourceGroupName
  location            = var.location
  sku                 = "Standard"
  sku_tier            = "Regional"
  allocation_method   = "Static"
  ip_version          = "IPv4"
  zones               = ["1", "2", "3"]

  lifecycle {
    prevent_destroy = true
  }
}

resource "azurerm_application_gateway" "network" {
  name                = local.appGatewayName
  resource_group_name = var.resourceGroupName
  location            = var.location

  depends_on = [
    azurerm_key_vault_access_policy.user_assigned_identity_keyvault_permissions,
    module.certificate
  ]

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.user_assigned_identity.id]
  }

  sku {
    name = "WAF_v2"
    tier = "WAF_v2"
  }

  ssl_certificate {
    name                = var.appGatewayFqdn
    key_vault_secret_id = "https://${var.keyVaultName}.vault.azure.net:443/secrets/${local.secretName}"
  }

  gateway_ip_configuration {
    name      = "appGatewayIpConfig"
    subnet_id = var.subnetId
  }

  frontend_ip_configuration {
    name                          = "appGwPublicFrontendIp"
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public_ip.id
  }

  frontend_port {
    name = "port_80"
    port = 80
  }

  frontend_port {
    name = "port_443"
    port = 443
  }

  backend_address_pool {
    name  = "apim"
    fqdns = [var.primaryBackendendFqdn]
  }

  backend_http_settings {
    name                                = "default"
    port                                = 80
    protocol                            = "Http"
    cookie_based_affinity               = "Disabled"
    pick_host_name_from_backend_address = false
    affinity_cookie_name                = "ApplicationGatewayAffinity"
    request_timeout                     = 20

  }

  backend_http_settings {
    name                                = "https"
    port                                = 443
    protocol                            = "Https"
    cookie_based_affinity               = "Disabled"
    host_name                           = var.primaryBackendendFqdn
    pick_host_name_from_backend_address = false
    request_timeout                     = 20
    probe_name                          = local.httpsBackendProbeName
  }

  http_listener {
    name                           = "default"
    frontend_ip_configuration_name = "appGwPublicFrontendIp"
    frontend_port_name             = "port_80"
    protocol                       = "Http"
    require_sni                    = false
  }

  http_listener {
    name                           = "https"
    frontend_ip_configuration_name = "appGwPublicFrontendIp"
    frontend_port_name             = "port_443"
    protocol                       = "Https"
    require_sni                    = false
    ssl_certificate_name           = var.appGatewayFqdn
  }

  request_routing_rule {
    name                       = "apim"
    rule_type                  = "Basic"
    http_listener_name         = "https"
    backend_address_pool_name  = "apim"
    backend_http_settings_name = "https"
    priority                   = 100
  }

  probe {
    name                                      = "APIM"
    protocol                                  = "Https"
    host                                      = var.primaryBackendendFqdn
    path                                      = var.probe_url
    interval                                  = 30
    timeout                                   = 30
    unhealthy_threshold                       = 3
    pick_host_name_from_backend_http_settings = false
    minimum_servers                           = 0

    match {
      status_code = ["200-399"]
    }
  }

  waf_configuration {
    enabled                  = true
    firewall_mode            = "Detection"
    rule_set_type            = "OWASP"
    rule_set_version         = "3.0"
    request_body_check       = true
    max_request_body_size_kb = 128
    file_upload_limit_mb     = 100
  }

  enable_http2 = true

  autoscale_configuration {
    min_capacity = 2
    max_capacity = 3
  }

  lifecycle {
    prevent_destroy = true
  }
}
