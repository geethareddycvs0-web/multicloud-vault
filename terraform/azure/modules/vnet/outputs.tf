output "vnet_id"           { value = azurerm_virtual_network.main.id }
output "public_subnet_id"  { value = azurerm_subnet.public.id }
output "private_subnet_id" { value = azurerm_subnet.private.id }
output "nsg_id"            { value = azurerm_network_security_group.web.id }
