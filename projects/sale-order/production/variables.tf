variable "resource_group_name" {
  description = "Resource group name"
  type        = string
  default     = "rg-hd-sales"
}

variable "location" {
  description = "Azure location"
  type        = string
  default     = "canadacentral"
}

variable "acr_name" {
  description = "Azure Container Registry name"
  type        = string
  default     = "salescontractapp"
}

variable "app_service_plan_sku" {
  description = "App Service Plan SKU"
  type        = string
  default     = "S1"
}

variable "backend_app_name" {
  description = "Backend App Service name"
  type        = string
  default     = "sales-order-backend"
}

variable "frontend_app_name" {
  description = "Frontend App Service name"
  type        = string
  default     = "sales-order-web"
}

variable "db_sku_name" {
  description = "Database SKU name"
  type        = string
  default     = "B_Standard_B1ms"
}

variable "db_storage_mb" {
  description = "Database storage in MB"
  type        = number
  default     = 32768
}

variable "db_admin_username" {
  description = "Database admin username"
  type        = string
  default     = "saleadmin"
}

variable "db_admin_password" {
  description = "Database admin password"
  type        = string
  sensitive   = true
}

variable "db_name" {
  description = "Database name"
  type        = string
  default     = "sale_order_db"
}

variable "better_auth_secret" {
  description = "Better Auth secret"
  type        = string
  sensitive   = true
}
