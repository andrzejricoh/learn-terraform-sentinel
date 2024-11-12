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
  instances      = 1
  size           = "Standard_B1s"
  admin_username = "andrzej"
}
