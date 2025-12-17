resource "azurerm_traffic_manager_profile" "tm1" {
  name                   = var.name
  resource_group_name    = var.resourceGroupName
  traffic_routing_method = "Performance"
  dns_config {
    relative_name = var.name
    ttl           = 60
  }
  monitor_config {
    expected_status_code_ranges = ["200-299"]
    path                        = var.probe_url
    port                        = 443
    protocol                    = "HTTPS"
  }
}

resource "azurerm_traffic_manager_azure_endpoint" "primaryEndpoint" {
  name                 = var.primaryName
  profile_id           = azurerm_traffic_manager_profile.tm1.id
  always_serve_enabled = false
  weight               = 100
  target_resource_id   = var.primaryPublicIpId



}

resource "azurerm_traffic_manager_azure_endpoint" "secondaryEndpoint" {
  name                 = var.secondaryName
  profile_id           = azurerm_traffic_manager_profile.tm1.id
  always_serve_enabled = false
  weight               = 100
  target_resource_id   = var.secondaryPublicIpId
}