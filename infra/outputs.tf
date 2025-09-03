output "resource_group" {
  description = "Resource group name"
  value       = data.azurerm_resource_group.project7.name
}

output "webapp_name" {
  description = "Web app name"
  value       = azurerm_linux_web_app.web.name
}