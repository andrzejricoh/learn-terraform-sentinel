output "vms" {
  value = [for key, pip in azurerm_public_ip.this : {
    name       = azurerm_linux_virtual_machine.this[key].computer_name
    fqdn       = pip.fqdn
    ip_address = pip.ip_address
    adminuser  = values(azurerm_linux_virtual_machine.this)[0].admin_username
  }]
  description = "VM Info"
}

output "current_context" {
  value = data.azurerm_client_config.current
}
