#-------------------------------
# Deploy CI/CD agent if required
#-------------------------------

resource "azurerm_network_interface" "vm_nic" {
  name                = "jumpbox-${var.environment}-nic"
  location            = azurerm_resource_group.shared_rg.location
  resource_group_name = azurerm_resource_group.shared_rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.cicd_agent_subnet_id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_windows_virtual_machine" "agent_vm" {
  name                = "jumpbox-${var.environment}"
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
# Deploy CI/CD agent extension using custom script
#-------------------------------
resource "azurerm_virtual_machine_extension" "deploy_agent" {
  count                = var.cicd_agent_type != "none" ? 1 : 0
  name                 = "devops_agent"
  virtual_machine_id   = azurerm_windows_virtual_machine.agent_vm.id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.10"

  settings = <<SETTINGS
    {
      "fileUris" : ["https://raw.githubusercontent.com/Azure/apim-landing-zone-accelerator/main/reference-implementations/AppGW-IAPIM-Func/bicep/shared/agentsetup.ps1"],
      "commandToExecute": "powershell -ExecutionPolicy Unrestricted -File agentsetup.ps1 -PAT \"${var.personal_access_token}\" -URL \"${var.account_name}\" -POOL \"${var.pool_name}\" -AGENT \"${azurerm_windows_virtual_machine.agent_vm.name}\" -AGENTTYPE \"${var.cicd_agent_type}\""
    }
SETTINGS
}