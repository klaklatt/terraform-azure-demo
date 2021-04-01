terraform {
  required_version = "~> 0.14.0"

  required_providers {
    azure = {
      source  = "hashicorp/azurerm"
      version = "~> 2.53.0"
    }
  }

  backend "azurerm" {}
}

provider "azure" {
  features {}
}

resource "azurerm_resource_group" "project" {
  name     = var.resource_group
  location = var.region
}