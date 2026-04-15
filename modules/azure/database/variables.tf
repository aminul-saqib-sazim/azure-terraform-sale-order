variable "name" {
  description = "Name of the PostgreSQL Flexible Server"
  type        = string
}

variable "location" {
  description = "Azure location"
  type        = string
}

variable "resource_group_name" {
  description = "Resource group name"
  type        = string
}

variable "pg_version" {
  description = "PostgreSQL version"
  type        = string
  default     = "16"
}

variable "sku_name" {
  description = "SKU name for PostgreSQL"
  type        = string
  default     = "B_Standard_B1ms"
}

variable "storage_mb" {
  description = "Storage size in MB"
  type        = number
  default     = 32768
}

variable "admin_username" {
  description = "Administrator username"
  type        = string
}

variable "admin_password" {
  description = "Administrator password"
  type        = string
  sensitive   = true
}

variable "database_name" {
  description = "Database name"
  type        = string
}

variable "public_network_access_enabled" {
  description = "Enable public network access"
  type        = bool
  default     = true
}

variable "backup_retention_days" {
  description = "Backup retention days"
  type        = number
  default     = 14
}

variable "firewall_rule_name" {
  description = "Firewall rule name"
  type        = string
  default     = "AllowClientIP"
}

variable "start_ip" {
  description = "Firewall start IP"
  type        = string
  default     = "0.0.0.0"
}

variable "end_ip" {
  description = "Firewall end IP"
  type        = string
  default     = "0.0.0.0"
}

variable "tags" {
  description = "Tags for resources"
  type        = map(string)
  default     = {}
}
