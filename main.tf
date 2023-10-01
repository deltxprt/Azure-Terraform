terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.75.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.5.1"
    }
  }
}


provider "azurerm" {
  features {}
}

resource "random_password" "test01_password" {
  length  = 25
  special = true
}

resource "azurerm_key_vault_secret" "test01-secret" {
  name         = "test01-delta"
  value        = random_password.test01_password.result
  key_vault_id = "/subscriptions/433a5766-0b1a-475e-aa9b-9556b6dab416/resourceGroups/Lab/providers/Microsoft.KeyVault/vaults/map-Vault-lab"
}

resource "azurerm_network_interface" "nic_test01" {
  name                = "test01-nic"
  location            = "canada central"
  resource_group_name = "dev"

  ip_configuration {
    name                          = "testconfiguration1"
    subnet_id                     = "/subscriptions/433a5766-0b1a-475e-aa9b-9556b6dab416/resourceGroups/Lab/providers/Microsoft.Network/virtualNetworks/vnet01-cace/subnets/default"
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_ssh_public_key" "hellgatrsa" {
  name                = "hellgatersa"
  resource_group_name = "dev"
  location            = "canada central"
  public_key          = file("HellgateRSA.pub")
}

resource "azurerm_linux_virtual_machine" "test01_vm" {
  name                = "test01"
  resource_group_name = "dev"
  location            = "canada central"
  size                = "Standard_B1ls"
  admin_username      = "delta"
  network_interface_ids = [
    azurerm_network_interface.nic_test01.id,
  ]

  admin_ssh_key {
    username   = "delta"
    public_key = file("HellgateRSA.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Debian"
    offer     = "debian-11"
    sku       = "11-backports-gen2"
    version   = "latest"
  }
}