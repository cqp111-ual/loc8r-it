# Loc8r IT 

######################
## Global resources ##
######################

# Resource group
resource "azurerm_resource_group" "tf-resource-group" {
  name     = var.azure-resource-group
  location = var.azure-location
}

# Network and subnetwork
resource "azurerm_virtual_network" "tf-net" {
  name                = var.azure-net-name
  location            = azurerm_resource_group.tf-resource-group.location
  resource_group_name = azurerm_resource_group.tf-resource-group.name
  address_space       = var.azure-address-space
  dns_servers         = var.azure-dns-servers
}

resource "azurerm_subnet" "tf-subnet" {
  name                 = var.azure-subnet-name
  resource_group_name  = azurerm_resource_group.tf-resource-group.name
  virtual_network_name = azurerm_virtual_network.tf-net.name
  address_prefixes     = var.azure-subnet-prefixes
  # depends_on           = [azurerm_virtual_network.tf-net]

}

# Security Group (common for all machines)
resource "azurerm_network_security_group" "tf-nsg" {
  name                = var.azure-nsg-name
  location            = azurerm_resource_group.tf-resource-group.location
  resource_group_name = azurerm_resource_group.tf-resource-group.name
  # depends_on          = [azurerm_resource_group.tf-resource-group]

  security_rule {
    name                       = "ssh"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "http"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "https"
    priority                   = 1003
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "mongo"
    priority                   = 1004
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "27017"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "jenkins-docker"
    priority                   = 1005
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "5000"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# No crearemos las maquinas de jenkins ni la maquina de build
# reutilizaremos las maquinas de la actividad 1 de CNSA
# - cnsa-jks-01.spaincentral.cloudapp.azure.com -> Jenkins
# - cnsa-dpl-01.spaincentral.cloudapp.azure.com -> Build

#### Staging node
# Public IP
resource "azurerm_public_ip" "tf-stage-ip" {
  name                = "${var.stage-vm-name}-ip"
  location            = azurerm_resource_group.tf-resource-group.location
  resource_group_name = azurerm_resource_group.tf-resource-group.name
  domain_name_label   = var.stage-vm-name
  allocation_method   = "Dynamic"
  sku                 = "Basic"
}

# Network interface
resource "azurerm_network_interface" "tf-stage-nic" {
  name                = "${var.stage-vm-name}-nic"
  location            = azurerm_resource_group.tf-resource-group.location
  resource_group_name = azurerm_resource_group.tf-resource-group.name

  ip_configuration {
    name      = "internal"
    subnet_id = azurerm_subnet.tf-subnet.id
    # # Here we can apply either Static or Dynamic
    # private_ip_address_allocation = "Dynamic"
    private_ip_address_allocation = "Static"
    private_ip_address            = var.stage-privateip-address
    public_ip_address_id          = azurerm_public_ip.tf-stage-ip.id
  }
}

resource "azurerm_network_interface_security_group_association" "tf-stage-nic-nsg" {
  network_interface_id      = azurerm_network_interface.tf-stage-nic.id
  network_security_group_id = azurerm_network_security_group.tf-nsg.id
}

# VM instance
resource "azurerm_linux_virtual_machine" "tf-stage" {
  name                = var.stage-vm-name
  resource_group_name = azurerm_resource_group.tf-resource-group.name
  location            = azurerm_resource_group.tf-resource-group.location
  size                = var.stage-vm-size
  admin_username      = var.azure-admin-username
  network_interface_ids = [
    azurerm_network_interface.tf-stage-nic.id,
  ]

  admin_ssh_key {
    username   = var.azure-admin-username
    public_key = file("${path.module}/keys/cnsa-cqp111.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = var.azure-storage-account-type
  }

  source_image_reference {
    publisher = var.azure-os-publisher
    offer     = var.azure-os-offer
    sku       = var.azure-os-sku
    version   = var.azure-os-version
  }

  # # does not work
  # user_data = base64encode(file("${path.module}/resources/00-install-docker.sh"))
}

output "tf-stage-fqdn" {
  value      = azurerm_public_ip.tf-stage-ip.fqdn
  depends_on = [azurerm_linux_virtual_machine.tf-stage]
}

output "tf-stage-public-ip" {
  value      = azurerm_public_ip.tf-stage-ip.ip_address
  depends_on = [azurerm_linux_virtual_machine.tf-stage]
}

#### Production node
# Public IP
resource "azurerm_public_ip" "tf-deploy-ip" {
  name                = "${var.deploy-vm-name}-ip"
  location            = azurerm_resource_group.tf-resource-group.location
  resource_group_name = azurerm_resource_group.tf-resource-group.name
  domain_name_label   = var.deploy-vm-name
  allocation_method   = "Dynamic"
  sku                 = "Basic"
}

# Network interface
resource "azurerm_network_interface" "tf-deploy-nic" {
  name                = "${var.deploy-vm-name}-nic"
  location            = azurerm_resource_group.tf-resource-group.location
  resource_group_name = azurerm_resource_group.tf-resource-group.name

  ip_configuration {
    name      = "internal"
    subnet_id = azurerm_subnet.tf-subnet.id
    # # Here we can apply either Static or Dynamic
    # private_ip_address_allocation = "Dynamic"
    private_ip_address_allocation = "Static"
    private_ip_address            = var.deploy-privateip-address
    public_ip_address_id          = azurerm_public_ip.tf-deploy-ip.id
  }
}

resource "azurerm_network_interface_security_group_association" "tf-deploy-nic-nsg" {
  network_interface_id      = azurerm_network_interface.tf-deploy-nic.id
  network_security_group_id = azurerm_network_security_group.tf-nsg.id
}

# VM instance
resource "azurerm_linux_virtual_machine" "tf-deploy" {
  name                = var.deploy-vm-name
  resource_group_name = azurerm_resource_group.tf-resource-group.name
  location            = azurerm_resource_group.tf-resource-group.location
  size                = var.deploy-vm-size
  admin_username      = var.azure-admin-username
  network_interface_ids = [
    azurerm_network_interface.tf-deploy-nic.id,
  ]

  admin_ssh_key {
    username   = var.azure-admin-username
    public_key = file("${path.module}/keys/cnsa-cqp111.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = var.azure-storage-account-type
  }

  source_image_reference {
    publisher = var.azure-os-publisher
    offer     = var.azure-os-offer
    sku       = var.azure-os-sku
    version   = var.azure-os-version
  }

  # # does not work
  # user_data = base64encode(file("${path.module}/resources/00-install-docker.sh"))
}

output "tf-deploy-fqdn" {
  value      = azurerm_public_ip.tf-deploy-ip.fqdn
  depends_on = [azurerm_linux_virtual_machine.tf-deploy]
}

output "tf-deploy-public-ip" {
  value      = azurerm_public_ip.tf-deploy-ip.ip_address
  depends_on = [azurerm_linux_virtual_machine.tf-deploy]
}
