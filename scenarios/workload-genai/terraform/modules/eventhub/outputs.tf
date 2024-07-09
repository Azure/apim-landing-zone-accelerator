output "eventHubNamespaceName" {
  description = "The name of the Event Hub Namespace."
  value       = azurerm_eventhub_namespace.eventHubNamespace.name
}

output "eventHubName" {
  description = "The name of the Event Hub."
  value       = azurerm_eventhub.eventHub.name
}
