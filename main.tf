data "azurerm_client_config" "current" {}

locals {
  prefix = "${replace(var.prefix, "/-*$/", "")}-"
  instance_map = {
    for idx in range(1, var.vm.instances + 1) :
    format("%02d", idx) => "${local.prefix}${format("%02d", idx)}-"
  }
}

resource "random_password" "admin_password" {
  count = var.admin_password == null ? 1 : 0

  length           = 16
  override_special = "!#%&*-=_"
}

# resource "tls_private_key" "this" {
#   algorithm = "RSA"
#   rsa_bits  = 4096
# }

resource "azurerm_resource_group" "this" {
  name     = "${local.prefix}rg"
  location = var.region

  tags = var.tags
}

resource "azurerm_virtual_network" "this" {
  address_space       = [var.cidr]
  dns_servers         = var.dns_servers
  location            = azurerm_resource_group.this.location
  name                = "${local.prefix}vnet"
  resource_group_name = azurerm_resource_group.this.name

  tags = var.tags
}

resource "azurerm_subnet" "this" {
  name                 = "${local.prefix}subnet"
  address_prefixes     = [var.cidr]
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
}

resource "azurerm_public_ip" "this" {
  for_each = local.instance_map

  name                = "${each.value}pip"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  sku                 = "Standard"
  domain_name_label   = trim(lower(substr(each.value, 0, 63)), "-")
  allocation_method   = "Static"
  zones               = ["1"]

  tags = var.tags
}

resource "azurerm_network_interface" "this" {
  for_each = local.instance_map

  name                = "${each.value}nic"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  dns_servers         = var.dns_servers
  ip_configuration {
    name                          = "${each.value}ipconf"
    subnet_id                     = azurerm_subnet.this.id
    private_ip_address_allocation = "Static"
    private_ip_address            = cidrhost(var.cidr, 3 + tonumber(each.key))
    public_ip_address_id          = azurerm_public_ip.this[each.key].id
  }

  tags = var.tags
}

resource "azurerm_linux_virtual_machine" "this" {
  for_each = local.instance_map

  name                            = "${each.value}vm"
  computer_name                   = azurerm_public_ip.this[each.key].domain_name_label
  location                        = azurerm_resource_group.this.location
  resource_group_name             = azurerm_resource_group.this.name
  size                            = var.vm.size
  admin_username                  = var.vm.admin_username
  admin_password                  = var.admin_password == null ? random_password.admin_password[0].result : var.admin_password
  disable_password_authentication = false
  network_interface_ids           = [azurerm_network_interface.this[each.key].id]
  provision_vm_agent              = false
  allow_extension_operations      = false

  # admin_ssh_key {
  #   username   = var.vm.admin_username
  #   public_key = tls_private_key.this.public_key_openssh
  # }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    disk_size_gb         = 30
    name                 = "${each.value}osdisk"
  }

  source_image_reference {
    publisher = "debian"
    offer     = "debian-12"
    sku       = "12-gen2"
    version   = "latest"
  }

  additional_capabilities {
    hibernation_enabled = false
    ultra_ssd_enabled   = false
  }

  boot_diagnostics {}

  identity {
    type = "SystemAssigned"
  }

  tags = var.tags

  # provisioner "local-exec" {
  #   command = "echo 'on apply 1'"
  # }

  # provisioner "local-exec" {
  #   command    = "echo ''on apply 2'" # this fails
  #   on_failure = continue
  # }

  # connection {
  #   type     = "ssh"
  #   user     = self.admin_username
  #   password = self.admin_password
  #   host     = self.public_ip_address
  # }

  # provisioner "remote-exec" {
  #   when = create
  #   inline = [
  #     "sudo ls -la",
  #   ]
  # }

  # provisioner "local-exec" {
  #   when    = destroy
  #   command = "echo 'on destroy'"
  # }

  lifecycle {
    ignore_changes = [
      admin_password
    ]
    # postcondition {
    #   condition = length(regexall("^/subscriptions/[a-z][a-zA-z0-9-/]*", self.id)) > 0
    #   error_message = "Postcondition failed"
    # }
    # create_before_destroy = true
  }
}
