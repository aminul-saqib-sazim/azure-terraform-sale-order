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

  database_server_name       = "${local.name_prefix}-db"
  database_fqdn              = "${local.database_server_name}.postgres.database.azure.com"
  database_connection_string = "postgresql://${var.db_admin_username}:${var.db_admin_password}@${local.database_fqdn}:5432/${var.db_name}?sslmode=require"
  acr_login_server           = "${var.acr_name}.azurecr.io"

  backend_default_url  = "https://${var.backend_app_name}.azurewebsites.net"
  frontend_default_url = "https://${var.frontend_app_name}.azurewebsites.net"

  backend_public_url  = var.enable_backend_custom_domain ? "https://${var.backend_custom_domain}" : local.backend_default_url
  frontend_public_url = var.enable_frontend_custom_domain ? "https://${var.frontend_custom_domain}" : local.frontend_default_url

  backend_logs = {
    detailed_error_messages = false
    failed_request_tracing  = false
    application_logs = {
      file_system_level = "Information"
    }
    http_logs = {
      retention_in_days = 3
      retention_in_mb   = 100
    }
  }

  backend_app_settings = merge(
    {
      API_BASE_URL                            = local.backend_public_url
      API_HEALTH_URL                          = "${local.backend_public_url}/api/v1/health"
      AWS_ACCESS_KEY_ID                       = ""
      AWS_REGION                              = "ca-central-1"
      AWS_S3_ENDPOINT                         = "https://s3.ca-central-1.amazonaws.com"
      AWS_SECRET_ACCESS_KEY                   = ""
      BE_PORT                                 = "5000"
      BETTER_AUTH_SECRET                      = var.better_auth_secret
      BETTER_AUTH_URL                         = local.frontend_public_url
      DATABASE_URL                            = local.database_connection_string
      DOCKER_ENABLE_CI                        = "true"
      DO_SPACES_BUCKET_NAME                   = "sazim-development-bucket-35938ff3"
      DO_SPACES_BUCKET_URL                    = "https://sazim-development-bucket-35938ff3.tor1.digitaloceanspaces.com"
      DO_SPACES_ENDPOINT                      = "https://tor1.digitaloceanspaces.com"
      DO_SPACES_PRESIGN_URL_EXPIRY_IN_MINUTES = "5"
      DO_SPACES_REGION                        = "tor1"
      ENABLE_AUDIT_LOGGING                    = "true"
      HD_HEAD_OFFICE_EMAIL                    = "hdoffice@example.com"
      MAGIC_LINK_EXPIRES_IN                   = "300"
      MAILGUN_DOMAIN                          = "hddecorating.com"
      MICROSOFT_TENANT_ID                     = var.tenant_id
      NODE_ENV                                = "production"
      ORGANIZATION_OWNER_EMAIL                = ""
      ORGANIZATION_OWNER_PASSWORD             = ""
      OTP_EXPIRES_IN                          = "300"
      SEND_FROM_EMAIL                         = "noreply@hddecorating.com"
      SESSION_EXPIRES_IN                      = "604800"
      SESSION_UPDATE_AGE                      = "86400"
      STAGE_ENV                               = "production"
      WEB_CLIENT_BASE_URL                     = local.frontend_public_url
      WEBSITES_CONTAINER_START_TIME           = "yarn start:prod"
      WEBSITES_ENABLE_APP_SERVICE_STORAGE     = "false"
      WEBSITES_PORT                           = "5000"
    },
    var.backend_app_settings_overrides,
  )

  frontend_app_settings = merge(
    {
      DOCKER_ENABLE_CI                    = "true"
      NEXT_PUBLIC_API_BASE_URL            = "${local.backend_public_url}/api/v1/"
      NEXT_PUBLIC_STAGE_ENV               = "production"
      NODE_ENV                            = "production"
      WEBSITES_CONTAINER_START_TIME       = "yarn start"
      WEBSITES_ENABLE_APP_SERVICE_STORAGE = "false"
      WEBSITES_PORT                       = "3000"
    },
    var.frontend_app_settings_overrides,
  )

  backend_slot_app_settings = merge(
    {
      ADMIN_EMAIL                             = ""
      ADMIN_PASSWORD                          = ""
      API_BASE_URL                            = local.backend_default_url
      API_HEALTH_URL                          = "${local.backend_default_url}/api/v1/health"
      AWS_ACCESS_KEY_ID                       = ""
      AWS_REGION                              = "ca-central-1"
      AWS_S3_ENDPOINT                         = "https://s3.ca-central-1.amazonaws.com"
      AWS_SECRET_ACCESS_KEY                   = ""
      BE_PORT                                 = "5000"
      BETTER_AUTH_SECRET                      = var.better_auth_secret
      BETTER_AUTH_URL                         = local.frontend_default_url
      DATABASE_URL                            = local.database_connection_string
      DEVELOPER_EMAIL                         = ""
      DEVELOPER_PASSWORD                      = ""
      DO_SPACES_BUCKET_NAME                   = "sale-order-bucket"
      DO_SPACES_BUCKET_URL                    = "https://sale-order-bucket.ca-central-1.digitaloceanspaces.com"
      DO_SPACES_ENDPOINT                      = "https://nyc3.digitaloceanspaces.com"
      DO_SPACES_PRESIGN_URL_EXPIRY_IN_MINUTES = "5"
      DO_SPACES_REGION                        = "ca-central-1"
      ENABLE_AUDIT_LOGGING                    = "false"
      HD_HEAD_OFFICE_EMAIL                    = "hdoffice@example.com"
      MAGIC_LINK_EXPIRES_IN                   = "300"
      MAILGUN_API_KEY                         = ""
      MAILGUN_DOMAIN                          = ""
      MICROSOFT_CLIENT_ID                     = ""
      MICROSOFT_CLIENT_SECRET                 = ""
      MICROSOFT_TENANT_ID                     = ""
      NODE_ENV                                = "production"
      ORGANIZATION_OWNER_EMAIL                = ""
      ORGANIZATION_OWNER_PASSWORD             = ""
      OTP_EXPIRES_IN                          = "300"
      SEND_FROM_EMAIL                         = "noreply@hddecorating.com"
      SESSION_EXPIRES_IN                      = "604800"
      SESSION_UPDATE_AGE                      = "86400"
      STAGE_ENV                               = "production"
      WEB_CLIENT_BASE_URL                     = local.frontend_default_url
    },
    var.backend_slot_app_settings_overrides,
  )

  frontend_slot_app_settings = merge(
    {
      BETTER_AUTH_SECRET       = var.better_auth_secret
      BETTER_AUTH_URL          = local.frontend_default_url
      NEXT_PUBLIC_API_BASE_URL = "${local.backend_default_url}/api/v1/"
      NEXT_PUBLIC_STAGE_ENV    = "production"
      NODE_ENV                 = "production"
    },
    var.frontend_slot_app_settings_overrides,
  )
}

# =============================================================================
# Azure Container Registry
# =============================================================================

resource "azurerm_container_registry" "this" {
  name                          = var.acr_name
  resource_group_name           = var.resource_group_name
  location                      = var.location
  sku                           = var.acr_sku
  admin_enabled                 = var.acr_admin_enabled
  anonymous_pull_enabled        = false
  data_endpoint_enabled         = false
  export_policy_enabled         = true
  network_rule_bypass_option    = "AzureServices"
  public_network_access_enabled = true
  quarantine_policy_enabled     = false
  trust_policy_enabled          = false
  zone_redundancy_enabled       = false

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_role_assignment" "acr_push" {
  scope                = azurerm_container_registry.this.id
  role_definition_name = "AcrPush"
  principal_id         = var.acr_push_principal_id
}

resource "azurerm_role_assignment" "acr_additional_pull" {
  for_each             = var.acr_additional_pull_principal_ids
  scope                = azurerm_container_registry.this.id
  role_definition_name = "AcrPull"
  principal_id         = each.value
}

# =============================================================================
# App Service (Backend)
# =============================================================================

module "app_service_backend" {
  source = "../../../../modules/azure/app-service"

  name                = var.app_service_plan_name
  create_service_plan = true
  location            = var.location
  resource_group_name = var.resource_group_name
  sku_name            = var.app_service_plan_sku

  app_name                 = var.backend_app_name
  docker_image_name        = var.backend_docker_image_name
  docker_registry_username = var.acr_admin_username
  docker_registry_password = var.acr_admin_password
  slot_docker_image_name   = var.backend_slot_docker_image_name
  acr_login_server         = local.acr_login_server
  health_check_path        = var.backend_health_check_path
  slot_name                = var.slot_name
  https_only               = false
  app_settings             = local.backend_app_settings
  slot_app_settings        = local.backend_slot_app_settings
  logs                     = local.backend_logs

  acr_resource_id = azurerm_container_registry.this.id

  tags = local.common_tags
}

# =============================================================================
# App Service (Frontend)
# =============================================================================

module "app_service_frontend" {
  source = "../../../../modules/azure/app-service"

  name                = var.app_service_plan_name
  create_service_plan = false
  service_plan_id     = module.app_service_backend.service_plan_id
  location            = var.location
  resource_group_name = var.resource_group_name
  sku_name            = var.app_service_plan_sku

  app_name                 = var.frontend_app_name
  docker_image_name        = var.frontend_docker_image_name
  docker_registry_username = var.acr_admin_username
  docker_registry_password = var.acr_admin_password
  slot_docker_image_name   = var.frontend_slot_docker_image_name
  acr_login_server         = local.acr_login_server
  health_check_path        = var.frontend_health_check_path
  slot_health_check_path   = var.frontend_slot_health_check_path
  slot_name                = var.slot_name
  https_only               = false
  app_settings             = local.frontend_app_settings
  slot_app_settings        = local.frontend_slot_app_settings

  acr_resource_id = azurerm_container_registry.this.id

  tags = local.common_tags
}

resource "azurerm_app_service_custom_hostname_binding" "backend" {
  count               = var.enable_backend_custom_domain ? 1 : 0
  hostname            = var.backend_custom_domain
  app_service_name    = module.app_service_backend.name
  resource_group_name = var.resource_group_name
}

resource "azurerm_app_service_managed_certificate" "backend" {
  count                      = var.enable_backend_custom_domain ? 1 : 0
  custom_hostname_binding_id = azurerm_app_service_custom_hostname_binding.backend[0].id

  lifecycle {
    ignore_changes = [custom_hostname_binding_id]
  }
}

resource "azurerm_app_service_certificate_binding" "backend" {
  count               = var.enable_backend_custom_domain ? 1 : 0
  hostname_binding_id = azurerm_app_service_custom_hostname_binding.backend[0].id
  certificate_id      = azurerm_app_service_managed_certificate.backend[0].id
  ssl_state           = "SniEnabled"
}

resource "azurerm_app_service_custom_hostname_binding" "frontend" {
  count               = var.enable_frontend_custom_domain ? 1 : 0
  hostname            = var.frontend_custom_domain
  app_service_name    = module.app_service_frontend.name
  resource_group_name = var.resource_group_name
}

resource "azurerm_app_service_managed_certificate" "frontend" {
  count                      = var.enable_frontend_custom_domain ? 1 : 0
  custom_hostname_binding_id = azurerm_app_service_custom_hostname_binding.frontend[0].id

  lifecycle {
    ignore_changes = [custom_hostname_binding_id]
  }
}

resource "azurerm_app_service_certificate_binding" "frontend" {
  count               = var.enable_frontend_custom_domain ? 1 : 0
  hostname_binding_id = azurerm_app_service_custom_hostname_binding.frontend[0].id
  certificate_id      = azurerm_app_service_managed_certificate.frontend[0].id
  ssl_state           = "SniEnabled"
}

resource "azurerm_container_registry_webhook" "backend" {
  count               = var.backend_cd_webhook_url != "" ? 1 : 0
  name                = "webappsaleorderbackend"
  location            = var.location
  resource_group_name = var.resource_group_name
  registry_name       = var.acr_name
  service_uri         = var.backend_cd_webhook_url
  actions             = ["push"]
  status              = "enabled"
  scope               = var.backend_acr_webhook_scope

  lifecycle {
    ignore_changes = [service_uri]
  }
}

resource "azurerm_container_registry_webhook" "frontend" {
  count               = var.frontend_cd_webhook_url != "" ? 1 : 0
  name                = "webappsaleorderweb"
  location            = var.location
  resource_group_name = var.resource_group_name
  registry_name       = var.acr_name
  service_uri         = var.frontend_cd_webhook_url
  actions             = ["push"]
  status              = "enabled"
  scope               = var.frontend_acr_webhook_scope

  lifecycle {
    ignore_changes = [service_uri]
  }
}

# =============================================================================
# Database
# =============================================================================

module "database" {
  source = "../../../../modules/azure/database"

  name                 = local.database_server_name
  location             = var.location
  resource_group_name  = var.resource_group_name
  sku_name             = var.db_sku_name
  storage_mb           = var.db_storage_mb
  zone                 = var.db_zone
  admin_username       = var.db_admin_username
  admin_password       = var.db_admin_password
  database_name        = var.db_name
  extra_firewall_rules = var.db_extra_firewall_rules

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
# Outputs
# =============================================================================

output "backend_app_url" {
  value = "https://${module.app_service_backend.default_hostname}"
}

output "frontend_app_url" {
  value = "https://${module.app_service_frontend.default_hostname}"
}

output "backend_custom_domain" {
  value = var.enable_backend_custom_domain ? var.backend_custom_domain : null
}

output "backend_custom_domain_verification_id" {
  value     = var.enable_backend_custom_domain ? module.app_service_backend.custom_domain_verification_id : null
  sensitive = true
}

output "frontend_custom_domain" {
  value = var.enable_frontend_custom_domain ? var.frontend_custom_domain : null
}

output "frontend_custom_domain_verification_id" {
  value     = var.enable_frontend_custom_domain ? module.app_service_frontend.custom_domain_verification_id : null
  sensitive = true
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
  value = azurerm_container_registry.this.login_server
}

output "application_insights_instrumentation_key" {
  value     = azurerm_application_insights.this.instrumentation_key
  sensitive = true
}
