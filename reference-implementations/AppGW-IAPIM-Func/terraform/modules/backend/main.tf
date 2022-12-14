# What will be deployed 

/*Contains:
 - Storage Account for Azure Function Apps
 - Application Service Plan for Azure Function Apps
 - Azure Function App with Code Stack (linux. dotnetcore)
 - Azure Function App with Container (linux, container)
 */


#-------------------------------
# Backend functions' resource group creation
#-------------------------------
resource "azurerm_resource_group" "backend_rg" {
  name     = "rg-backend-${var.resource_suffix}"
  location = var.location
}

#-------------------------------
# Storage account creation for Functions 
#-----------------------------

resource "azurerm_storage_account" "backend_storage_account" {
  name                     = lower(trim("stbackend${var.workload_name}${var.location}", "-"))
  resource_group_name      = azurerm_resource_group.backend_rg.name
  location                 = azurerm_resource_group.backend_rg.location
  account_tier             = var.storage_account_tier
  account_replication_type = var.storage_replication_type
}

#-------------------------------
# ASP for the function apps 
#-----------------------------

resource "azurerm_service_plan" "function_app_service_plan" {
  name                = "asp-${var.resource_suffix}"
  location            = azurerm_resource_group.backend_rg.location
  resource_group_name = azurerm_resource_group.backend_rg.name

  sku_name = var.sp_sku
  os_type  = "Linux"
}

#-------------------------------
# Azure function app (Linux, .NET Core 3.1)
#-------------------------------

resource "azurerm_linux_function_app" "function_app" {
  name                        = "func-code-${var.resource_suffix}"
  resource_group_name         = azurerm_resource_group.backend_rg.name
  location                    = azurerm_resource_group.backend_rg.location
  service_plan_id             = azurerm_service_plan.function_app_service_plan.id
  https_only                  = true
  storage_account_name        = azurerm_storage_account.backend_storage_account.name
  storage_account_access_key  = azurerm_storage_account.backend_storage_account.primary_access_key
  functions_extension_version = "~4"
  app_settings = {
    "WEBSITE_RUN_FROM_PACKAGE" = "",
    "FUNCTIONS_WORKER_RUNTIME" = "dotnet",
  }


  site_config {
    use_32_bit_worker = false

    application_stack {
      dotnet_version = "3.1"
    }

    ip_restriction {
      virtual_network_subnet_id = var.backend_subnet_id
    }
  }

  lifecycle {
    ignore_changes = [
      app_settings["WEBSITE_RUN_FROM_PACKAGE"],
    ]
  }
}

#-------------------------------
# Azure function app (Container)
#-------------------------------

resource "azurerm_linux_function_app" "function_app_container" {
  name                        = "func-cont-${var.resource_suffix}"
  resource_group_name         = azurerm_resource_group.backend_rg.name
  location                    = azurerm_resource_group.backend_rg.location
  service_plan_id             = azurerm_service_plan.function_app_service_plan.id
  https_only                  = true
  storage_account_name        = azurerm_storage_account.backend_storage_account.name
  storage_account_access_key  = azurerm_storage_account.backend_storage_account.primary_access_key
  functions_extension_version = "~4"

  app_settings = {
    "WEBSITE_RUN_FROM_PACKAGE" = "",
    "FUNCTIONS_WORKER_RUNTIME" = "dotnet",
  }

  site_config {
    use_32_bit_worker = false

    application_stack {
      docker {
        registry_url = "mcr.microsoft.com"
        image_name   = "azure-functions/dotnet"
        image_tag    = "latest"
      }
    }

    ip_restriction {
      virtual_network_subnet_id = var.backend_subnet_id
    }
  }

  lifecycle {
    ignore_changes = [
      app_settings["WEBSITE_RUN_FROM_PACKAGE"],
    ]
  }
}

