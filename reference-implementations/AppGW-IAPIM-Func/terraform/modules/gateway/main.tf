locals {
  app_gateway_name         = "appgw-${var.resource_suffix}"
  app_gateway_primary_pip  = "pip-${local.app_gateway_name}"
  app_gateway_identity_id  = "identity-${local.app_gateway_name}"
  https_backend_probe_name = "APIM"
  is_local_certificate     = var.app_gateway_certificate_type == "custom"
  certificate_secret_id    = local.is_local_certificate ? azurerm_key_vault_certificate.kv_domain_certs[0].secret_id : azurerm_key_vault_certificate.local_domain_certs[0].secret_id
}

resource "azurerm_user_assigned_identity" "user_assigned_identity" {
  resource_group_name = var.resource_group_name
  location            = var.resource_group_location

  name = local.app_gateway_identity_id
}

resource "azurerm_key_vault_access_policy" "user_assigned_identity_keyvault_permissions" {
  key_vault_id = var.keyvault_id
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
}

resource "azurerm_key_vault_certificate" "kv_domain_certs" {
  count        = local.is_local_certificate ? 1 : 0
  name         = var.secret_name
  key_vault_id = var.keyvault_id

  certificate {
    contents = filebase64(var.certificate_path)
    password = var.certificate_password
  }

  certificate_policy {
    issuer_parameters {
      name = "Self"
    }

    key_properties {
      exportable = true
      key_size   = 256
      key_type   = "EC"
      reuse_key  = false
      curve      = "P-256"
    }

    secret_properties {
      content_type = "application/x-pkcs12"
    }
  }
}

resource "azurerm_key_vault_certificate" "local_domain_certs" {
  count        = !local.is_local_certificate ? 1 : 0
  name         = "generated-cert"
  key_vault_id = var.keyvault_id

  certificate_policy {
    issuer_parameters {
      name = "Self"
    }

    key_properties {
      exportable = true
      key_size   = 2048
      key_type   = "RSA"
      reuse_key  = true
    }

    lifetime_action {
      action {
        action_type = "AutoRenew"
      }

      trigger {
        days_before_expiry = 30
      }
    }

    secret_properties {
      content_type = "application/x-pkcs12"
    }

    x509_certificate_properties {
      extended_key_usage = ["1.3.6.1.5.5.7.3.1"]
      key_usage = [
        "digitalSignature",
        "keyEncipherment"
      ]
      subject            = "CN=${var.fqdn}"
      validity_in_months = 12
    }
  }
}

resource "azurerm_public_ip" "public_ip" {
  name                = local.app_gateway_primary_pip
  resource_group_name = var.resource_group_name
  location            = var.resource_group_location
  sku                 = "Standard"
  ip_version          = "IPv4"
  allocation_method   = "Static"
}

resource "azurerm_application_gateway" "network" {
  name                = local.app_gateway_name
  resource_group_name = var.resource_group_name
  location            = var.resource_group_location

  depends_on = [
    azurerm_key_vault_access_policy.user_assigned_identity_keyvault_permissions,
    azurerm_key_vault_certificate.kv_domain_certs
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
    name                = var.fqdn
    key_vault_secret_id = local.certificate_secret_id
  }

  gateway_ip_configuration {
    name      = "appGatewayIpConfig"
    subnet_id = var.subnet_id
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
    fqdns = [var.primary_backendend_fqdn]
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
    host_name                           = var.primary_backendend_fqdn
    pick_host_name_from_backend_address = false
    request_timeout                     = 20
    probe_name                          = local.https_backend_probe_name
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
    ssl_certificate_name           = var.fqdn
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
    host                                      = var.primary_backendend_fqdn
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
}