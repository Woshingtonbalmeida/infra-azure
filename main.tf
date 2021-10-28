provider "azurerm" {
  features {}
  # Acesso ao portal do Azure
  subscription_id = "56bf8671-3634-4be0-9b69-db3eb1291dfa"
  client_id       = "4327f2a5-e3ff-4b4e-a6ef-6d2fea6999f6"
  client_secret   = "A2x8s0AaxvVdJ2H0bR3.2gAwHHAGcI~HAC"
  tenant_id       = "988a37e7-292a-4184-bd95-faf1b013d6a0"
}

# Configure the AWS Provider
provider "aws" {
  region     = var.aws_region
  access_key = var.aws_access_key_id
  secret_key = var.aws_secret_access_key
}
resource "azurerm_resource_group" "rg" {
  name     = "RG-CP2-EUA"
  location = "West US"

  tags = {
    Name = "LOCALIZA-CP02"
  }
}
resource "azurerm_virtual_network" "vnet" {
  name                = "VNET-CP2"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.0.0.0/16"]
  tags = {
    Name = "VNET-REDE10"
  }
}
resource "azurerm_subnet" "sub" {
  name                 = "RedePrivate"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]

}

resource "azurerm_subnet" "gs" {
  name                 = "GatewaySubnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}
resource "azurerm_network_interface" "nic" {
  name                = "NIC-VM-W2k16"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.sub.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.ipvm.id

  }
  tags = {
    Name = "NIC-VM01"
  }
}
resource "azurerm_public_ip" "ipvm" {
  name                = "PIP-VM-W2k16"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  allocation_method   = "Dynamic"

  tags = {
    Name = "PIP-VM01"
  }
}
resource "azurerm_windows_virtual_machine" "vmw" {
  name                = "VM-W2k16"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = "Standard_F2"
  admin_username      = "adminuser"
  admin_password      = "P@$$w0rd1234!"
  network_interface_ids = [azurerm_network_interface.nic.id,
  ]

  os_disk {
    name                 = "S.O-VM-W2k16"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }
  tags = {
    Name = "AZURE-CP2"
  }
}
