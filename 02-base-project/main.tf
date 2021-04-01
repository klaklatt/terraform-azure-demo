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

resource "azurerm_virtual_network" "project" {
  name                = "vnet"
  address_space       = ["192.168.0.0/16"]
  location            = azurerm_resource_group.project.location
  resource_group_name = azurerm_resource_group.project.name
}

resource "azurerm_subnet" "public" {
  name                 = "public-subnet"
  resource_group_name  = azurerm_resource_group.project.name
  virtual_network_name = azurerm_virtual_network.project.name
  address_prefixes     = ["192.168.10.0/24"]
}

resource "azurerm_subnet" "private" {
  name                 = "private-subnet"
  resource_group_name  = azurerm_resource_group.project.name
  virtual_network_name = azurerm_virtual_network.project.name
  address_prefixes     = ["192.168.11.0/24"]
}

resource "azurerm_network_security_group" "private" {
  name                = "private-subnet-nsg"
  location            = azurerm_resource_group.project.location
  resource_group_name = azurerm_resource_group.project.name
}

resource "azurerm_subnet_network_security_group_association" "private" {
  subnet_id                 = azurerm_subnet.private.id
  network_security_group_id = azurerm_network_security_group.private.id
}

resource "azurerm_network_security_group" "public" {
  name                = "public-subnet-nsg"
  location            = azurerm_resource_group.project.location
  resource_group_name = azurerm_resource_group.project.name
}

resource "azurerm_subnet_network_security_group_association" "public" {
  subnet_id                 = azurerm_subnet.public.id
  network_security_group_id = azurerm_network_security_group.public.id
}