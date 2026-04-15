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
}

# =============================================================================
# Existing Resources (Data Sources)
# =============================================================================

data "azurerm_container_registry" "existing" {
  name                = var.acr_name
  resource_group_name = var.resource_group_name
}

# =============================================================================
# App Service (Backend)
# =============================================================================

module "app_service_backend" {
  source = "../../../modules/azure/app-service"

  name                = "${local.name_prefix}-sp"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku_name            = var.app_service_plan_sku

  app_name          = var.backend_app_name
  docker_image_name = "salescontractapp.azurecr.io/sale-order-backend:latest"
  acr_login_server  = data.azurerm_container_registry.existing.login_server
  health_check_path = "/api/v1/health"
  slot_name         = "staging"

  acr_resource_id = data.azurerm_container_registry.existing.id

  tags = local.common_tags
}

# =============================================================================
# App Service (Frontend)
# =============================================================================

module "app_service_frontend" {
  source = "../../../modules/azure/app-service"

  name                = "${local.name_prefix}-fe-sp"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku_name            = var.app_service_plan_sku

  app_name          = var.frontend_app_name
  docker_image_name = "salescontractapp.azurecr.io/sale-order-web:latest"
  acr_login_server  = data.azurerm_container_registry.existing.login_server
  health_check_path = "/"
  slot_name         = "staging"

  acr_resource_id = data.azurerm_container_registry.existing.id

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
# Key Vault
# =============================================================================

resource "azurerm_key_vault" "this" {
  name                = "${local.name_prefix}-kv"
  location            = var.location
  resource_group_name = var.resource_group_name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"

  tags = local.common_tags
}

resource "azurerm_key_vault_secret" "db_password" {
  name         = "db-password"
  value        = var.db_admin_password
  key_vault_id = azurerm_key_vault.this.id
}

resource "azurerm_key_vault_secret" "better_auth_secret" {
  name         = "better-auth-secret"
  value        = var.better_auth_secret
  key_vault_id = azurerm_key_vault.this.id
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

output "key_vault_name" {
  value = azurerm_key_vault.this.name
}

output "application_insights_instrumentation_key" {
  value     = azurerm_application_insights.this.instrumentation_key
  sensitive = true
}
