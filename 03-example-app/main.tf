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

data "azurerm_subnet" "private" {
  name                 = "private-subnet"
  virtual_network_name = "vnet"
  resource_group_name  = var.resource_group
}

locals {
  custom_data = <<EOF
    #cloud-config
    package_upgrade: true
    packages:
      - apache2
    write_files:
      - owner: www-data:www-data
      - path: /var/www/html/index.html
        content: |
            Example App
    runcmd:
      - service apache2 restart
  EOF
}

resource "azurerm_linux_virtual_machine_scale_set" "example_app" {
  name                = "example-app-vmss"
  resource_group_name = var.resource_group
  location            = var.region
  sku                 = "Standard_B1ls"
  instances           = 2
  admin_username      = "adminuser"

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

  network_interface {
    name    = "example-app-nic"
    primary = true

    ip_configuration {
      name                                   = "internal"
      primary                                = true
      subnet_id                              = data.azurerm_subnet.private.id
      load_balancer_backend_address_pool_ids = [azurerm_lb_backend_address_pool.example_app.id]
    }
  }

  custom_data = base64encode(local.custom_data)

  health_probe_id = azurerm_lb_probe.example_app.id
}

resource "azurerm_public_ip" "example_app" {
  name                = "Example-App-LB-PIP"
  location            = var.region
  resource_group_name = var.resource_group
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_lb" "example_app" {
  name                = "Example-App-LB"
  location            = var.region
  resource_group_name = var.resource_group

  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.example_app.id
  }

  sku = "Standard"
}

resource "azurerm_lb_backend_address_pool" "example_app" {
  loadbalancer_id = azurerm_lb.example_app.id
  name            = "BackEndAddressPool"
}

resource "azurerm_lb_probe" "example_app" {
  resource_group_name = var.resource_group
  loadbalancer_id     = azurerm_lb.example_app.id
  name                = "http-running-probe"
  port                = 80
}

resource "azurerm_lb_rule" "example_app" {
  resource_group_name            = var.resource_group
  loadbalancer_id                = azurerm_lb.example_app.id
  name                           = "http"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  backend_address_pool_id        = azurerm_lb_backend_address_pool.example_app.id
  frontend_ip_configuration_name = "PublicIPAddress"
  probe_id                       = azurerm_lb_probe.example_app.id
}