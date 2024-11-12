variable "region" {
  description = "Azure region"
  type        = string
  # default     = "West Europe"
}

variable "prefix" {
  description = "Unique project prefix"
  type        = string
  # default     = "andrzej-cube-test"
}

variable "tags" {
  description = "Common resource tags"
  type        = map(string)
}

variable "cidr" {
  description = "VNET CIDR"
  type        = string
  # default     = "andrzej-cube-test"
}

variable "dns_servers" {
  description = "DNS Servers"
  type        = list(string)
  nullable    = false
}

variable "admin_password" {
  description = "VM password"
  type        = string
  sensitive   = true
  default     = null
}

variable "vm" {
  description = "Azure VM Parameters"
  type = object({
    instances      = optional(number, 1)
    size           = optional(string, "Standard_B2s")
    admin_username = string
  })
}
