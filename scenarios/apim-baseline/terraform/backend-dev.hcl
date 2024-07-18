backend "azurerm" {
	resource_group_name = "rg-tfstate-eastus2"
	storage_account_name = "tfstateeastus98"
	container_name       = "apimlz"
	key                  = "terraform-apimlz.tfstate"
}
