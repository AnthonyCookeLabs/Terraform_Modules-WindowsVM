provider "azurerm" {
  subscription_id = "e9323b12-8e1e-4dde-9d38-fbdd05cd7eaf"
  client_id       = "d58ff129-d89f-4372-83a5-9f30ac555387"
  client_secret   = "cd381ed8-6f74-4b97-b1f5-d83196db73b7"
  tenant_id       = "6015445a-413d-4f17-b8a0-2cb3147c39c6"
  features {}
}

# Create a resource group
resource "azurerm_resource_group" "rg" {
    name     = var.windowsvmrgname
    location = var.location
    tags     = var.tags
}

resource "azurerm_virtual_network" "vnet" {
  name                = "${var.prefix}${var.environment}-vnet"
  address_space       = var.address_space
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  tags     = var.tags
}

resource "azurerm_subnet" "subnet" {
  name                 = "${var.prefix}${var.environment}-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes       = var.address_prefix
}

resource "azurerm_public_ip" "pip" {
  name                = "${var.prefix}${var.environment}-pip"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  allocation_method   = "Dynamic"
}

resource "azurerm_network_interface" "publicnic" {
  name                = "${var.prefix}${var.environment}-pubnic"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  ip_configuration {
    name                          = "${var.prefix}${var.environment}-pubipconfig"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip.id
  }
}

resource "azurerm_network_interface" "intnic" {
  name                      = "${var.prefix}${var.environment}-intnic"
  resource_group_name       = azurerm_resource_group.rg.name
  location                  = azurerm_resource_group.rg.location

  ip_configuration {
    name                          = "${var.prefix}${var.environment}-intipconfig"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_security_group" "NSG" {
  name                = "${var.prefix}${var.environment}-NSG"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  security_rule {
    access                     = "Allow"
    direction                  = "Inbound"
    name                       = "RDP_Allow"
    priority                   = 100
    protocol                   = "Tcp"
    source_port_range          = "*"
    source_address_prefix      = "*"
    destination_port_range     = "3389"
    destination_address_prefix = azurerm_network_interface.publicnic.private_ip_address
  }
}

resource "azurerm_network_interface_security_group_association" "nsgassoc" {
  network_interface_id      = azurerm_network_interface.publicnic.id
  network_security_group_id = azurerm_network_security_group.NSG.id
}

resource "azurerm_windows_virtual_machine" "main" {
  name                            = "${var.prefix}-vm"
  resource_group_name             = azurerm_resource_group.rg.name
  location                        = azurerm_resource_group.rg.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@ssw0rd1234!"
  network_interface_ids = [
    azurerm_network_interface.publicnic.id,
    azurerm_network_interface.intnic.id,
  ]

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

  
}
output "ip" {
		    value = azurerm_public_ip.pip.ip_address
  }