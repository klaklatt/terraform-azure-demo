output "resource_group" {
  value = azurerm_resource_group.admin_project.name
}

output "storage_account" {
  value = azurerm_storage_account.terraform_state.name
}