terraform {
  required_version = "~> 0.15.0"

  required_providers {
    azure = {
      source  = "hashicorp/azurerm"
      version = "~> 2.57.0"
    }
  }
}

provider "azure" {
  features {}
}

resource "azurerm_resource_group" "admin_project" {
  name     = var.resource_group
  location = var.region
}

resource "random_integer" "storage_account" {
  min = 100000
  max = 999999
}

resource "azurerm_storage_account" "terraform_state" {
  name                     = "terraformstate${random_integer.storage_account.id}"
  resource_group_name      = azurerm_resource_group.admin_project.name
  location                 = azurerm_resource_group.admin_project.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "terraform_state" {
  name                  = "tf-state-container"
  storage_account_name  = azurerm_storage_account.terraform_state.name
  container_access_type = "private"
}