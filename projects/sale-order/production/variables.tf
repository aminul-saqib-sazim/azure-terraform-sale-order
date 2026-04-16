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

variable "aws_access_key_id" {
  description = "AWS Access Key ID for S3 storage"
  type        = string
  default     = ""
}

variable "aws_secret_access_key" {
  description = "AWS Secret Access Key for S3 storage"
  type        = string
  default     = ""
  sensitive   = true
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ca-central-1"
}

variable "do_spaces_region" {
  description = "DigitalOcean Spaces region (used for S3 compatibility)"
  type        = string
  default     = "ca-central-1"
}

variable "do_spaces_bucket_name" {
  description = "DigitalOcean Spaces/S3 bucket name"
  type        = string
  default     = ""
}

variable "do_spaces_bucket_url" {
  description = "DigitalOcean Spaces/S3 bucket URL"
  type        = string
  default     = ""
}

variable "do_spaces_endpoint" {
  description = "DigitalOcean Spaces/S3 endpoint URL"
  type        = string
  default     = ""
}

variable "do_spaces_presign_url_expiry_in_minutes" {
  description = "Presigned URL expiry in minutes"
  type        = number
  default     = 5
}

variable "microsoft_client_id" {
  description = "Microsoft/Office 365 SSO Client ID"
  type        = string
  default     = ""
}

variable "microsoft_client_secret" {
  description = "Microsoft/Office 365 SSO Client Secret"
  type        = string
  default     = ""
  sensitive   = true
}

variable "microsoft_tenant_id" {
  description = "Microsoft/Office 365 SSO Tenant ID"
  type        = string
  default     = ""
}

variable "docuseal_api_key" {
  description = "DocuSeal API key"
  type        = string
  default     = ""
  sensitive   = true
}

variable "docuseal_webhook_secret" {
  description = "DocuSeal webhook secret"
  type        = string
  default     = ""
  sensitive   = true
}

variable "mailgun_api_key" {
  description = "Mailgun API key"
  type        = string
  default     = ""
  sensitive   = true
}

variable "mailgun_domain" {
  description = "Mailgun domain"
  type        = string
  default     = ""
}

variable "send_from_email" {
  description = "Sender email address for emails"
  type        = string
  default     = ""
}

variable "developer_email" {
  description = "Developer email for emergency access"
  type        = string
  default     = ""
}

variable "developer_password" {
  description = "Developer password for emergency access"
  type        = string
  default     = ""
  sensitive   = true
}

variable "admin_email" {
  description = "Admin email for emergency access"
  type        = string
  default     = ""
}

variable "admin_password" {
  description = "Admin password for emergency access"
  type        = string
  default     = ""
  sensitive   = true
}

variable "organization_owner_email" {
  description = "Organization owner email"
  type        = string
  default     = ""
}

variable "organization_owner_password" {
  description = "Organization owner password"
  type        = string
  default     = ""
  sensitive   = true
}

variable "hd_head_office_email" {
  description = "HD Head Office email for receiving signed contracts"
  type        = string
  default     = ""
}

variable "enable_audit_logging" {
  description = "Enable audit logging"
  type        = bool
  default     = false
}

variable "session_expires_in" {
  description = "Session expiry time in seconds (default: 7 days)"
  type        = number
  default     = 604800
}

variable "session_update_age" {
  description = "Session update age in seconds (default: 1 day)"
  type        = number
  default     = 86400
}

variable "magic_link_expires_in" {
  description = "Magic link expiry in seconds"
  type        = number
  default     = 300
}

variable "otp_expires_in" {
  description = "OTP expiry in seconds"
  type        = number
  default     = 300
}

variable "backend_startup_command" {
  description = "Backend startup command"
  type        = string
  default     = "yarn start:prod"
}

variable "frontend_startup_command" {
  description = "Frontend startup command"
  type        = string
  default     = "yarn start"
}

variable "acr_password" {
  description = "Azure Container Registry password for image pull"
  type        = string
  default     = ""
  sensitive   = true
}
