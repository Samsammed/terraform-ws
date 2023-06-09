# Création des sorties
output "resource_group_name" {
  value = azurerm_resource_group.rg.name
}

output "vm_ips" {
  value = [azurerm_network_interface.myvmnic.*.private_ip_address]
}
