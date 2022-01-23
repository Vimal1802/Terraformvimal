#################################################################
# Configure the Microsoft Azure Provider
#################################################################
provider "azurerm" {
  features { }

  subscription_id = "87885563-6f39-47c1-ba08-bf84b37b27ff"
  client_id = "32b98f2d-ac51-4ea3-9bce-3049a915beb5"
  client_secret = "YdmZ585G841J6LWfqj1CaJ.LeBzh.F-ZuG"
  tenant_id = "38de821a-c32f-43e6-972c-53978b228f09"
}

##########################################################
## Create Resource group 
##########################################################
resource "azurerm_resource_group" "rg1" {
  name     = "ProjectFYP"
  location = "East US"
}

##########################################################
## Create Automation account 
##########################################################

resource "azurerm_automation_account" "aa1" {
  name                = "ProjectFYP2022"
  location            = azurerm_resource_group.rg1.location
  resource_group_name = azurerm_resource_group.rg1.name

  sku_name = "Basic"

}

##########################################################
## Create Log Analytics Workspace account 
##########################################################

resource "azurerm_log_analytics_workspace" "law1" {
  name                = "ProjectFYPWorkspace"
  location            = azurerm_resource_group.rg1.location
  resource_group_name = azurerm_resource_group.rg1.name
  sku                 = "pergb2018"
}

##########################################################
## Create Virtual Net , Subnet and NIC
##########################################################

resource "azurerm_virtual_network" "vnet" {
  name                = "vNet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg1.location
  resource_group_name = azurerm_resource_group.rg1.name
}

resource "azurerm_subnet" "subnet" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.rg1.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefix       = "10.0.1.0/24"
}

##########################################################
## Create Public IP
##########################################################

resource "azurerm_public_ip" "FYPvm1publicip" {
  name = "FYP1pip1"
  location = "East US"
  resource_group_name = azurerm_resource_group.rg1.name
  allocation_method = "Static"
  sku = "Basic"
}

resource "azurerm_public_ip" "FYPvm2publicip" {
  name = "FYP2pip1"
  location = "East US"
  resource_group_name = azurerm_resource_group.rg1.name
  allocation_method = "Static"
  sku = "Basic"
}

resource "azurerm_public_ip" "FYPvm3publicip" {
  name = "FYP3pip1"
  location = "East US"
  resource_group_name = azurerm_resource_group.rg1.name
  allocation_method = "Static"
  sku = "Basic"
}

resource "azurerm_network_interface" "nic1" {
  name                = "FYPNic"
  location            = azurerm_resource_group.rg1.location
  resource_group_name = azurerm_resource_group.rg1.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.FYPvm1publicip.id
  }
}

resource "azurerm_network_interface" "nic2" {
  name                = "FYPNic2"
  location            = azurerm_resource_group.rg1.location
  resource_group_name = azurerm_resource_group.rg1.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.FYPvm2publicip.id
  }
}

resource "azurerm_network_interface" "nic3" {
  name                = "FYPNic3"
  location            = azurerm_resource_group.rg1.location
  resource_group_name = azurerm_resource_group.rg1.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.FYPvm3publicip.id
  }
}


resource "azurerm_network_security_group" "nsg1" {
  name                = "FYPNetworkSecurityGroup"
  location            = azurerm_resource_group.rg1.location
  resource_group_name = azurerm_resource_group.rg1.name

  security_rule {
    name                       = "AllowConnections"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

##########################################################
## Link Log Analytics Workspace account to Automation
##########################################################

resource "azurerm_log_analytics_linked_service" "aala1" {
  resource_group_name = azurerm_resource_group.rg1.name
  workspace_name = azurerm_log_analytics_workspace.law1.name
  resource_id = "/subscriptions/87885563-6f39-47c1-ba08-bf84b37b27ff/resourceGroups/ProjectFYP/providers/Microsoft.Automation/automationAccounts/ProjectFYP2022"
}

##########################################################
## Create Virtual Machines
##########################################################

resource "azurerm_virtual_machine" "VM1" {
  name                  = "FYPVM1"
  location              = azurerm_resource_group.rg1.location
  resource_group_name   = azurerm_resource_group.rg1.name
  network_interface_ids = [azurerm_network_interface.nic1.id]
  vm_size               = "Standard_B1ms"

storage_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }
  storage_os_disk {
    name              = "myosdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "FYP1"
    admin_username = "VimalFYP"
    admin_password = "Vimal1802"
  }
  os_profile_windows_config {
    provision_vm_agent = false
  }
}

resource "azurerm_virtual_machine" "VM2" {
  name                  = "FYPVM2"
  location              = azurerm_resource_group.rg1.location
  resource_group_name   = azurerm_resource_group.rg1.name
  network_interface_ids = [azurerm_network_interface.nic2.id]
  vm_size               = "Standard_B1ms"

storage_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }
  storage_os_disk {
    name              = "myosdisk2"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "FYP2"
    admin_username = "VimalFYP"
    admin_password = "Vimal1802"
  }
  os_profile_windows_config {
    provision_vm_agent = false
  }
}

resource "azurerm_virtual_machine" "VM3" {
  name                  = "FYPVM3"
  location              = azurerm_resource_group.rg1.location
  resource_group_name   = azurerm_resource_group.rg1.name
  network_interface_ids = [azurerm_network_interface.nic3.id]
  vm_size               = "Standard_B1ms"

storage_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }
  storage_os_disk {
    name              = "myosdisk3"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "FYP3"
    admin_username = "VimalFYP"
    admin_password = "Vimal1802"
  }
  os_profile_windows_config {
    provision_vm_agent = false
  }
}


