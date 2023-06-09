
# Création du groupe de ressources
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

# Création des machines virtuelles
resource "azurerm_linux_virtual_machine" "my_terraform_vm" {
  count = var.vm_count

  name                  = "myvm${count.index}"
  location              = var.location
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.myvmnic[count.index].id]
  size                  = "Standard_B1s"

  os_disk {
    name                 = "myOsDisk"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  computer_name                   = "myvm${count.index}"
  admin_username                  = "azureuser"
  disable_password_authentication = true

  admin_ssh_key {
    username   = "azureuser"
    public_key = filesha256("./id_rsa")

  }

  boot_diagnostics {
    storage_account_uri = azurerm_storage_account.my_storage_account[count.index].primary_blob_endpoint
  }
}

#Création du réseau virtuel

resource "azurerm_virtual_network" "myvnet" {
  name                = "myvnet"
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
}


#Création des subnets 

resource "azurerm_subnet" "frontendsubnet" {
  name                 = "frontendsubnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.myvnet.name
  address_prefixes     = ["10.0.2.0/24"]
}


# Création des interfaces réseau
resource "azurerm_network_interface" "myvmnic" {
  count               = var.vm_count
  name                = "myvm${count.index}-nic"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.frontendsubnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.myvmpublicip[count.index].id
  }
}

# Création des adresses IP publiques
resource "azurerm_public_ip" "myvmpublicip" {
  count               = var.vm_count
  name                = "myvm${count.index}-publicip"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Dynamic"
}


# Create storage account for boot diagnostics

resource "azurerm_storage_account" "my_storage_account" {
  count                    = var.vm_count
  name                     = "diag${count.index}"
  location                 = "northeurope"
  resource_group_name      = azurerm_resource_group.rg.name
  account_tier             = "Standard"
  account_replication_type = "LRS"
}


