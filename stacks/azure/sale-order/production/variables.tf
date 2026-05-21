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

variable "acr_sku" {
  description = "Azure Container Registry SKU"
  type        = string
  default     = "Basic"
}

variable "acr_admin_enabled" {
  description = "Enable the admin account for ACR"
  type        = bool
  default     = true
}

variable "acr_push_principal_id" {
  description = "Principal ID with AcrPush on the registry"
  type        = string
  default     = "58e27361-0d45-463b-ac20-8f812b9e4c31"
}

variable "acr_additional_pull_principal_ids" {
  description = "Additional principals that currently have AcrPull on the registry"
  type        = set(string)
  default = [
    "398e0424-0eda-4548-ab2b-96eda23a6165",
    "dd59f337-a91b-493f-9512-dd0899820124",
  ]
}

variable "tenant_id" {
  description = "Azure tenant ID for production app settings"
  type        = string
  default     = "f480eed2-167f-4661-a2ee-ce2d5a29ecf4"
}

variable "app_service_plan_sku" {
  description = "App Service Plan SKU"
  type        = string
  default     = "S1"
}

variable "app_service_plan_name" {
  description = "Shared App Service Plan name"
  type        = string
  default     = "sale-order-prod-sp"
}

variable "backend_app_name" {
  description = "Backend App Service name"
  type        = string
  default     = "sale-order-backend"
}

variable "frontend_app_name" {
  description = "Frontend App Service name"
  type        = string
  default     = "sale-order-web"
}

variable "backend_docker_image_name" {
  description = "Backend container image"
  type        = string
  default     = "sale-order-backend:1.9.4"
}

variable "backend_slot_docker_image_name" {
  description = "Backend slot container image"
  type        = string
  default     = ""
}

variable "frontend_docker_image_name" {
  description = "Frontend container image"
  type        = string
  default     = "sale-order-web:1.9.4"
}

variable "frontend_slot_docker_image_name" {
  description = "Frontend slot container image"
  type        = string
  default     = "sale-order-web"
}

variable "acr_admin_username" {
  description = "ACR admin username used by the live App Services"
  type        = string
  default     = "salescontractapp"
}

variable "acr_admin_password" {
  description = "ACR admin password used by the live App Services"
  type        = string
  default     = null
  nullable    = true
  sensitive   = true
}

variable "slot_name" {
  description = "Deployment slot name"
  type        = string
  default     = "prod"
}

variable "backend_health_check_path" {
  description = "Health check path for the backend app"
  type        = string
  default     = "/api/v1/health"
}

variable "frontend_health_check_path" {
  description = "Health check path for the frontend app"
  type        = string
  default     = "/sign-in"
}

variable "frontend_slot_health_check_path" {
  description = "Health check path for the frontend slot"
  type        = string
  default     = "/"
}

variable "backend_custom_domain" {
  description = "Custom domain for the backend App Service"
  type        = string
  default     = "api.sales.hddecorating.com"
}

variable "enable_backend_custom_domain" {
  description = "Enable the backend custom domain, managed certificate, and binding"
  type        = bool
  default     = true
}

variable "frontend_custom_domain" {
  description = "Custom domain for the frontend App Service"
  type        = string
  default     = "sales.hddecorating.com"
}

variable "enable_frontend_custom_domain" {
  description = "Enable the frontend custom domain, managed certificate, and binding"
  type        = bool
  default     = true
}

variable "backend_app_settings_overrides" {
  description = "Override or secret app settings for the backend app"
  type        = map(string)
  default     = {}
  sensitive   = true
}

variable "frontend_app_settings_overrides" {
  description = "Override or secret app settings for the frontend app"
  type        = map(string)
  default     = {}
  sensitive   = true
}

variable "backend_slot_app_settings_overrides" {
  description = "Override or secret app settings for the backend slot"
  type        = map(string)
  default     = {}
  sensitive   = true
}

variable "frontend_slot_app_settings_overrides" {
  description = "Override or secret app settings for the frontend slot"
  type        = map(string)
  default     = {}
  sensitive   = true
}

variable "backend_acr_webhook_scope" {
  description = "ACR webhook scope for backend continuous deployment"
  type        = string
  default     = "sale-order-backend:latest"
}

variable "frontend_acr_webhook_scope" {
  description = "ACR webhook scope for frontend continuous deployment"
  type        = string
  default     = "sale-order-web:1.7.3"
}

variable "backend_cd_webhook_url" {
  description = "Backend App Service continuous deployment webhook URL"
  type        = string
  default     = ""
  sensitive   = true
}

variable "frontend_cd_webhook_url" {
  description = "Frontend App Service continuous deployment webhook URL"
  type        = string
  default     = ""
  sensitive   = true
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

variable "db_zone" {
  description = "Database availability zone"
  type        = string
  default     = "1"
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

variable "db_extra_firewall_rules" {
  description = "Additional PostgreSQL firewall rules"
  type = map(object({
    start_ip_address = string
    end_ip_address   = string
  }))
  default = {}
}

variable "better_auth_secret" {
  description = "Better Auth secret"
  type        = string
  sensitive   = true
}
