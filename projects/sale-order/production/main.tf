terraform {
  required_version = ">= 1.9.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

provider "azurerm" {
  features {}
  resource_provider_registrations = "none"
}

# =============================================================================
# Local Variables
# =============================================================================

locals {
  project_name = "sale-order"
  environment  = "prod"
  name_prefix  = "${local.project_name}-${local.environment}"

  common_tags = {
    Project     = "Sale Order App"
    Environment = local.environment
    ManagedBy   = "Terraform"
  }

  backend_app_hostname  = "${var.backend_app_name}.azurewebsites.net"
  frontend_app_hostname = "${var.frontend_app_name}.azurewebsites.net"
}

# =============================================================================
# Existing Resources (Data Sources)
# =============================================================================

data "azurerm_container_registry" "existing" {
  name                = var.acr_name
  resource_group_name = var.resource_group_name
}

# =============================================================================
# Shared App Service Plan (Single Plan for Cost Optimization)
# =============================================================================

resource "azurerm_service_plan" "shared" {
  name                = "${local.name_prefix}-sp"
  location            = var.location
  resource_group_name = var.resource_group_name
  os_type             = "Linux"
  sku_name            = var.app_service_plan_sku

  tags = local.common_tags
}

# =============================================================================
# App Service (Backend)
# =============================================================================

module "app_service_backend" {
  source = "../../../modules/azure/app-service"

  service_plan_id = azurerm_service_plan.shared.id

  location            = var.location
  resource_group_name = var.resource_group_name

  app_name          = var.backend_app_name
  docker_image_name = "salescontractapp.azurecr.io/sale-order-backend:latest"
  acr_login_server  = data.azurerm_container_registry.existing.login_server
  health_check_path = "/api/v1/health"
  slot_name         = "prod"
  startup_command   = var.backend_startup_command

  acr_resource_id = data.azurerm_container_registry.existing.id

  app_settings = merge(
    {
      NODE_ENV                                = "production"
      STAGE_ENV                               = "production"
      BE_PORT                                 = "5000"
      API_BASE_URL                            = "https://${local.backend_app_hostname}"
      API_HEALTH_URL                          = "https://${local.backend_app_hostname}/api/v1/health"
      DATABASE_URL                            = "postgresql://${var.db_admin_username}:${var.db_admin_password}@${module.database.fqdn}:5432/${var.db_name}?sslmode=require"
      WEB_CLIENT_BASE_URL                     = "https://${local.frontend_app_hostname}"
      BETTER_AUTH_URL                         = "https://${local.frontend_app_hostname}"
      DO_SPACES_REGION                        = var.do_spaces_region
      DO_SPACES_BUCKET_NAME                   = var.do_spaces_bucket_name
      DO_SPACES_BUCKET_URL                    = var.do_spaces_bucket_url
      DO_SPACES_ENDPOINT                      = var.do_spaces_endpoint
      DO_SPACES_PRESIGN_URL_EXPIRY_IN_MINUTES = var.do_spaces_presign_url_expiry_in_minutes
      AWS_ACCESS_KEY_ID                       = var.aws_access_key_id
      AWS_SECRET_ACCESS_KEY                   = var.aws_secret_access_key
      AWS_REGION                              = var.aws_region
      AWS_S3_ENDPOINT                         = "https://s3.${var.aws_region}.amazonaws.com"
      ENABLE_AUDIT_LOGGING                    = var.enable_audit_logging ? "true" : "false"
      SESSION_EXPIRES_IN                      = var.session_expires_in
      SESSION_UPDATE_AGE                      = var.session_update_age
      MAGIC_LINK_EXPIRES_IN                   = var.magic_link_expires_in
      OTP_EXPIRES_IN                          = var.otp_expires_in
      MICROSOFT_CLIENT_ID                     = var.microsoft_client_id
      MICROSOFT_CLIENT_SECRET                 = var.microsoft_client_secret
      MICROSOFT_TENANT_ID                     = var.microsoft_tenant_id
      DOCUSEAL_API_KEY                        = var.docuseal_api_key
      DOCUSEAL_WEBHOOK_SECRET                 = var.docuseal_webhook_secret
      MAILGUN_API_KEY                         = var.mailgun_api_key
      MAILGUN_DOMAIN                          = var.mailgun_domain
      SEND_FROM_EMAIL                         = var.send_from_email
      DEVELOPER_EMAIL                         = var.developer_email
      DEVELOPER_PASSWORD                      = var.developer_password
      ADMIN_EMAIL                             = var.admin_email
      ADMIN_PASSWORD                          = var.admin_password
      ORGANIZATION_OWNER_EMAIL                = var.organization_owner_email
      ORGANIZATION_OWNER_PASSWORD             = var.organization_owner_password
      HD_HEAD_OFFICE_EMAIL                    = var.hd_head_office_email
      BETTER_AUTH_SECRET                      = var.better_auth_secret
    },
    var.aws_access_key_id != "" ? {} : {}
  )

  tags = local.common_tags
}

# =============================================================================
# App Service (Frontend)
# =============================================================================

module "app_service_frontend" {
  source = "../../../modules/azure/app-service"

  service_plan_id = azurerm_service_plan.shared.id

  location            = var.location
  resource_group_name = var.resource_group_name

  app_name          = var.frontend_app_name
  docker_image_name = "salescontractapp.azurecr.io/sale-order-web:latest"
  acr_login_server  = data.azurerm_container_registry.existing.login_server
  health_check_path = "/"
  slot_name         = "prod"
  startup_command   = var.frontend_startup_command

  acr_resource_id = data.azurerm_container_registry.existing.id

  app_settings = {
    NODE_ENV                 = "production"
    NEXT_PUBLIC_STAGE_ENV    = "production"
    NEXT_PUBLIC_API_BASE_URL = "https://${local.backend_app_hostname}/api/v1/"
    BETTER_AUTH_SECRET       = var.better_auth_secret
    BETTER_AUTH_URL          = "https://${local.frontend_app_hostname}"
  }

  tags = local.common_tags
}

# =============================================================================
# Database
# =============================================================================

module "database" {
  source = "../../../modules/azure/database"

  name                = "${local.name_prefix}-db"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku_name            = var.db_sku_name
  storage_mb          = var.db_storage_mb
  admin_username      = var.db_admin_username
  admin_password      = var.db_admin_password
  database_name       = var.db_name

  tags = local.common_tags
}

# =============================================================================
# Application Insights
# =============================================================================

resource "azurerm_application_insights" "this" {
  name                = "${local.name_prefix}-ai"
  location            = var.location
  resource_group_name = var.resource_group_name
  application_type    = "web"
  retention_in_days   = 30

  tags = local.common_tags
}

# =============================================================================
# Log Analytics Workspace
# =============================================================================

resource "azurerm_log_analytics_workspace" "this" {
  name                = "${local.name_prefix}-law"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = 30

  tags = local.common_tags
}

# =============================================================================
# Data Sources
# =============================================================================

data "azurerm_client_config" "current" {}

# =============================================================================
# Outputs
# =============================================================================

output "backend_app_url" {
  value = "https://${module.app_service_backend.default_hostname}"
}

output "frontend_app_url" {
  value = "https://${module.app_service_frontend.default_hostname}"
}

output "backend_app_name" {
  value = var.backend_app_name
}

output "frontend_app_name" {
  value = var.frontend_app_name
}

output "db_fqdn" {
  value = module.database.fqdn
}

output "db_connection_string" {
  value     = module.database.connection_string
  sensitive = true
}

output "acr_login_server" {
  value = data.azurerm_container_registry.existing.login_server
}

output "application_insights_instrumentation_key" {
  value     = azurerm_application_insights.this.instrumentation_key
  sensitive = true
}

output "app_service_plan_name" {
  value = azurerm_service_plan.shared.name
}