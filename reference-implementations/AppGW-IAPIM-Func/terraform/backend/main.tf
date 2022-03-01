# What will be deployed 

/*Contains:
 - Storage Account for Azure Function Apps
 - Application Service Plan for Azure Function Apps
 - Azure Function App with Code Stack (linux. dotnetcore)
 - Azure Function App with Container (linux, container)*/


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
  name = lower(trim("stbackend${var.workload_name}${var.location}", "-"))
  resource_group_name = azurerm_resource_group.backend_rg.name
  location = azurerm_resource_group.backend_rg.location
  account_tier = var.storage_account_tier
  account_replication_type = var.storage_replication_type
}

#-------------------------------
# ASP for the function apps 
#-----------------------------

resource "azurerm_app_service_plan" "function_app_asp" {
  name                = "asp-${var.resource_suffix}"
  location            = azurerm_resource_group.backend_rg.location
  resource_group_name = azurerm_resource_group.backend_rg.name

  sku {
    tier = var.asp_tier
    size = var.asp_size
  }
  kind                = "Linux"
  reserved            = true
}

#-------------------------------
# Azure function app (Linux, .NET Core 3.1)
#-------------------------------

resource "azurerm_function_app" "function_app" {
  name                       = "func-${var.resource_suffix}"
  resource_group_name        = azurerm_resource_group.backend_rg.name
  location                   = azurerm_resource_group.backend_rg.location
  app_service_plan_id        = azurerm_app_service_plan.function_app_asp.id
  app_settings = {
    "WEBSITE_RUN_FROM_PACKAGE" = "",
    "FUNCTIONS_WORKER_RUNTIME" = "dotnet",
  # "APPINSIGHTS_INSTRUMENTATIONKEY" = azurerm_application_insights.application_insights.instrumentation_key,
  }
  https_only = true
  os_type = var.os_type
  
  site_config {
    linux_fx_version          = "dotnetcore|3.1" # az webapp list-runtimes --linux
    use_32_bit_worker_process = false

    ip_restriction {
      virtual_network_subnet_id = var.backend_subnet_id
    }
  }
  
  storage_account_name       = azurerm_storage_account.backend_storage_account.name
  version                    = "~3"


  lifecycle {
    ignore_changes = [
      app_settings["WEBSITE_RUN_FROM_PACKAGE"],
    ]
  }
}

#-------------------------------
# Azure function app (Container)
#-------------------------------