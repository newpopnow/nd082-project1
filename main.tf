provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "main" {
  name     = "${var.prefix}-resources"
  location = var.location
}

resource "azurerm_virtual_network" "main" {
  name                = "${var.prefix}-network"
  address_space       = ["10.0.0.0/22"]
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
}

resource "azurerm_subnet" "internal" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_interface" "main" {
  count               = var.vm_count
//  id                  = azurerm_network_
  name                = "${var.prefix}-nic${count.index}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.internal.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_security_group" "main" {
  name = "${var.prefix}-nsg"
  resource_group_name = azurerm_resource_group.main.name
  location = azurerm_resource_group.main.location

  security_rule {
    name = "Allow-subnet-access"
    priority = 100
    direction = "Inbound"
    access = "Allow"
    protocol = "Tcp"
    source_port_range = "*"
    destination_port_range = "*"
    source_address_prefix = "VirtualNetwork"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface_security_group_association" "main" {
  count = var.vm_count
  network_interface_id = azurerm_network_interface.main[count.index].id
  network_security_group_id = azurerm_network_security_group.main.id
}

resource "azurerm_public_ip" "main" {
    name = "${var.prefix}-publicip"
    resource_group_name = azurerm_resource_group.main.name
    location = azurerm_resource_group.main.location
    sku = "Standard"
    allocation_method = "Static"
  
}

resource "azurerm_lb" "main" {
    name = "${var.prefix}-lb"
    location = azurerm_resource_group.main.location
    resource_group_name = azurerm_resource_group.main.name
    sku = "Standard"
    frontend_ip_configuration {
      name = "PublicIPAddr"
      public_ip_address_id = azurerm_public_ip.main.id
    }
}

resource "azurerm_lb_rule" "main" {
  loadbalancer_id = azurerm_lb.main.id
  name = "lbrule"
  protocol = "Tcp"
  frontend_port = "80"
  backend_port = "80"
  frontend_ip_configuration_name = "PublicIPAddr"
}

resource "azurerm_lb_backend_address_pool" "main" {
  name = "${var.prefix}-lb-backend"
  loadbalancer_id = azurerm_lb.main.id
}

resource "azurerm_lb_backend_address_pool_address" "main" {
  name = "${var.prefix}-lb-pooladdr"
  backend_address_pool_id = azurerm_lb_backend_address_pool.main.id
  //virtual_network_id = azurerm_virtual_network.main.id
  }

resource "azurerm_network_interface_backend_address_pool_association" "main" {
  count = var.vm_count
  network_interface_id = azurerm_network_interface.main[count.index].id
  backend_address_pool_id = azurerm_lb_backend_address_pool.main.id
  ip_configuration_name = "internal"
  
}

resource "azurerm_availability_set" "main" {
    name = "${var.prefix}-vmas"
    resource_group_name = azurerm_resource_group.main.name
    location = azurerm_resource_group.main.location
    platform_fault_domain_count = var.platform_fault_domain_count
    platform_update_domain_count = var.platform_update_domain_count
}


data "azurerm_image" "packerimage" {
//    count = var.vm_count
    name = var.packer_image_name
    resource_group_name = "Azuredevops"
}


resource "azurerm_virtual_machine" "main" {
  count                           = var.vm_count
  name                            = "${var.prefix}-vm${count.index}"
  resource_group_name             = azurerm_resource_group.main.name
  location                        = azurerm_resource_group.main.location
  vm_size                         = "Standard_D2s_v3"
  delete_os_disk_on_termination = true
  delete_data_disks_on_termination = true
  os_profile {
    computer_name = "host-${count.index}"
    admin_username                  = var.admin_username
    admin_password                  = var.admin_password
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  network_interface_ids = [
    azurerm_network_interface.main[count.index].id,
  ]

  storage_image_reference {
    id = data.azurerm_image.packerimage.id
  }

  storage_os_disk {
    name = "osdisk-${count.index}"
    create_option = "FromImage"
    managed_disk_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

  storage_data_disk {
   name = "datadisk-${count.index}"
   lun = 0
   create_option = "Empty"
   caching = "ReadWrite"
   disk_size_gb = 30
   managed_disk_type = "Standard_LRS"
  }

  availability_set_id = azurerm_availability_set.main.id
}
