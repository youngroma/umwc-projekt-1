terraform {
  required_version = ">= 1.5.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.80"
    }
  }
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

locals {
  student_id = "50539" # <<< WPISZ SWÓJ NUMER INDEKSU
  location   = "italynorth"
  rg_name    = "rg-lab-${local.student_id}"
  vnet_name  = "vnet-${local.student_id}"
  subnet     = "snet-${local.student_id}"
  pip_name   = "pip-${local.student_id}"
  nsg_name   = "nsg-${local.student_id}"
  nic_name   = "nic-${local.student_id}"
  vm_name    = "vm-${local.student_id}"
  admin_user = "azureuser"
  admin_pass = "LabPassword123!"
}

resource "azurerm_resource_group" "lab" {
  name     = local.rg_name
  location = local.location
}

resource "azurerm_virtual_network" "lab" {
  name                = local.vnet_name
  location            = local.location
  resource_group_name = azurerm_resource_group.lab.name
  address_space       = ["10.10.0.0/16"]
}

resource "azurerm_subnet" "lab" {
  name                 = local.subnet
  resource_group_name  = azurerm_resource_group.lab.name
  virtual_network_name = azurerm_virtual_network.lab.name
  address_prefixes     = ["10.10.1.0/24"]
}

resource "azurerm_public_ip" "lab" {
  name                = local.pip_name
  location            = local.location
  resource_group_name = azurerm_resource_group.lab.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_network_security_group" "lab" {
  name                = local.nsg_name
  location            = local.location
  resource_group_name = azurerm_resource_group.lab.name

  security_rule {
    name                       = "Allow-SSH-22"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface" "lab" {
  name                = local.nic_name
  location            = local.location
  resource_group_name = azurerm_resource_group.lab.name

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.lab.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.lab.id
  }
}

resource "azurerm_network_interface_security_group_association" "lab" {
  network_interface_id      = azurerm_network_interface.lab.id
  network_security_group_id = azurerm_network_security_group.lab.id
}

resource "azurerm_linux_virtual_machine" "lab" {
  name                = local.vm_name
  resource_group_name = azurerm_resource_group.lab.name
  location            = local.location
  size                = "Standard_B1s"
  admin_username      = local.admin_user
  admin_password      = local.admin_pass
  disable_password_authentication = false
  network_interface_ids = [azurerm_network_interface.lab.id]

  os_disk {
    name                 = "osdisk-${local.student_id}"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }
}

output "public_ip" {
  value = "ssh azureuser@${azurerm_public_ip.lab.ip_address}"
}