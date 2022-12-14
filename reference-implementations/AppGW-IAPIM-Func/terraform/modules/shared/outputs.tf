output "workspace_id" {
  description = "The id of the workspace"
  value       = azurerm_log_analytics_workspace.log_analytics_workspace.id
}

output "instrumentation_key" {
  description = "The instrumentation key of the workspace"
  value       = azurerm_application_insights.shared_apim_insight.instrumentation_key
}

output "key_vault_id" {
  value = azurerm_key_vault.key_vault.id
}