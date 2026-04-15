# =============================================================================
# App Service Plan
# =============================================================================

resource "azurerm_service_plan" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  os_type             = "Linux"
  sku_name            = var.sku_name

  tags = var.tags
}

# =============================================================================
# Linux Web App with Container Configuration
# =============================================================================

resource "azurerm_linux_web_app" "this" {
  name                = var.app_name
  resource_group_name = var.resource_group_name
  location            = var.location
  service_plan_id     = azurerm_service_plan.this.id

  site_config {
    http2_enabled                     = true
    health_check_path                 = var.health_check_path
    health_check_eviction_time_in_min = 2
    minimum_tls_version               = "1.2"

    dynamic "application_stack" {
      for_each = var.docker_image_name != "" ? [1] : []
      content {
        docker_image_name   = var.docker_image_name
        docker_registry_url = var.acr_login_server != "" ? "https://${var.acr_login_server}" : null
      }
    }
  }

  app_settings = var.startup_command != "" ? {
    WEBSITES_CONTAINER_START_TIME = var.startup_command
  } : {}

  identity {
    type = "SystemAssigned"
  }

  tags = var.tags
}

# =============================================================================
# App Service Slot (Staging)
# =============================================================================

resource "azurerm_linux_web_app_slot" "this" {
  name           = var.slot_name
  app_service_id = azurerm_linux_web_app.this.id

  site_config {
    http2_enabled                     = true
    health_check_path                 = var.health_check_path
    health_check_eviction_time_in_min = 2
    minimum_tls_version               = "1.2"

    dynamic "application_stack" {
      for_each = var.docker_image_name != "" ? [1] : []
      content {
        docker_image_name   = var.docker_image_name
        docker_registry_url = var.acr_login_server != "" ? "https://${var.acr_login_server}" : null
      }
    }
  }

  identity {
    type = "SystemAssigned"
  }

  tags = var.tags
}

# =============================================================================
# ACR Pull Role Assignment (Main App)
# =============================================================================

resource "azurerm_role_assignment" "acr_pull" {
  scope                = var.acr_resource_id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_linux_web_app.this.identity[0].principal_id
}

# =============================================================================
# ACR Pull Role Assignment (Staging Slot)
# =============================================================================

resource "azurerm_role_assignment" "acr_pull_slot" {
  scope                = var.acr_resource_id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_linux_web_app_slot.this.identity[0].principal_id
}

# =============================================================================
# Outputs
# =============================================================================

output "id" {
  value = azurerm_linux_web_app.this.id
}

output "name" {
  value = azurerm_linux_web_app.this.name
}

output "default_hostname" {
  value = azurerm_linux_web_app.this.default_hostname
}

output "principal_id" {
  value = azurerm_linux_web_app.this.identity[0].principal_id
}

output "service_plan_id" {
  value = azurerm_service_plan.this.id
}

output "slot_id" {
  value = azurerm_linux_web_app_slot.this.id
}

output "slot_name" {
  value = var.slot_name
}
