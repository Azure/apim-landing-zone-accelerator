#-------------------------------
# Shared Resource group creation
#-------------------------------
resource "azurerm_resource_group" "shared_rg" {
  name     = "rg-shared-${var.resource_suffix}"
  location = var.location
}

#-------------------------------
# Creation of log analytics workspace instance 
#-------------------------------

resource "azurerm_log_analytics_workspace" "log_analytics_workspace" {
  name                = "log-${var.resource_suffix}"
  location            = azurerm_resource_group.shared_rg.location
  resource_group_name = azurerm_resource_group.shared_rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

#-------------------------------
# Creation of an application inisight instance 
#-------------------------------

resource "azurerm_application_insights" "shared_apim_insight" {
  name                = "appi-${var.resource_suffix}"
  location            = azurerm_resource_group.shared_rg.location
  resource_group_name = azurerm_resource_group.shared_rg.name
  application_type    = "web"
  workspace_id        = azurerm_log_analytics_workspace.log_analytics_workspace.id
}


#-------------------------------
# Creation of a key vault instance
#-------------------------------

data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "key_vault" {
  name                        = trim(substr("kv-${var.resource_suffix}", 0, 24), "-")
  location                    = azurerm_resource_group.shared_rg.location
  resource_group_name         = azurerm_resource_group.shared_rg.name
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  sku_name                    = var.key_vault_sku

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
      "Get",
    ]

    secret_permissions = [
      "Get",
    ]

    storage_permissions = [
      "Get",
    ]
  }
}

#-------------------------------
# Creation of a VM instance
#-------------------------------

resource "azurerm_network_interface" "vm_nic" {
  name                = "vm-nic-${var.resource_suffix}"
  location            = azurerm_resource_group.shared_rg.location
  resource_group_name = azurerm_resource_group.shared_rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.cicd_agent_subnet_id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_windows_virtual_machine" "agent_vm" {
  name                = "${var.cicd_agent_type}-${var.environment}"
  resource_group_name = azurerm_resource_group.shared_rg.name
  location            = azurerm_resource_group.shared_rg.location
  size                = "Standard_F2" 
  admin_username      = var.vm_username
  admin_password      = var.vm_password 
  network_interface_ids = [
    azurerm_network_interface.vm_nic.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }
}

#-------------------------------
# Deploy CI/CD agent if required
#-------------------------------
resource "azurerm_virtual_machine_extension" "deploy_agent" {
  name                 = "devops_agent_test"
  virtual_machine_id   = azurerm_windows_virtual_machine.agent_vm.id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.9"
 
  settings = <<SETTINGS
    {
      "fileUris" : "https://raw.githubusercontent.com/Azure/apim-landing-zone-accelerator/main/reference-implementations/AppGW-IAPIM-Func/bicep/shared/agentsetup.ps1",
      "commandToExecute": "powershell -ExecutionPolicy Unrestricted -File agentsetup.ps1 -PAT \"${var.personal_access_token}\" -URL \"${var.account_name}\" -POOl \"${var.pool_name}\" -AGENT \"${azurerm_windows_virtual_machine.agent_vm.name}\" -AGENTTYPE \"${var.cicd_agent_type}\""
    }
SETTINGS
}