region = "westeurope"
prefix = "single-vm-test"
tags = {
  Environment     = "dev",
  Department      = "IT",
  ApplicationName = "single-vm-test",
}
cidr        = "10.2.1.0/28"
dns_servers = ["8.8.8.8", "1.1.1.1"]
vm = {
  instances      = 3
  size           = "Standard_B32s_v2"
  admin_username = "andrzej"
}
