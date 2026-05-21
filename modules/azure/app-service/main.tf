# =============================================================================
# App Service Plan
# =============================================================================

locals {
  effective_service_plan_id   = var.create_service_plan ? azurerm_service_plan.this[0].id : var.service_plan_id
  effective_slot_health_check = var.slot_health_check_path != null ? var.slot_health_check_path : var.health_check_path
  effective_slot_docker_image = var.slot_docker_image_name != null ? var.slot_docker_image_name : var.docker_image_name
}

resource "azurerm_service_plan" "this" {
  count               = var.create_service_plan ? 1 : 0
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
  name                          = var.app_name
  resource_group_name           = var.resource_group_name
  location                      = var.location
  enabled                       = true
  service_plan_id               = local.effective_service_plan_id
  client_affinity_enabled       = false
  client_certificate_enabled    = false
  client_certificate_mode       = "Required"
  https_only                    = var.https_only
  public_network_access_enabled = true

  site_config {
    always_on                         = var.always_on
    ftps_state                        = "Disabled"
    http2_enabled                     = true
    health_check_path                 = var.health_check_path
    health_check_eviction_time_in_min = 2
    ip_restriction_default_action     = "Allow"
    load_balancing_mode               = "LeastRequests"
    minimum_tls_version               = "1.2"
    scm_ip_restriction_default_action = "Allow"
    scm_minimum_tls_version           = "1.2"
    scm_use_main_ip_restriction       = false
    use_32_bit_worker                 = true
    websockets_enabled                = false
    worker_count                      = 1

    dynamic "application_stack" {
      for_each = var.docker_image_name != "" ? [1] : []
      content {
        docker_image_name        = var.docker_image_name
        docker_registry_url      = var.acr_login_server != "" ? "https://${var.acr_login_server}" : null
        docker_registry_username = var.docker_registry_username
        docker_registry_password = var.docker_registry_password
      }
    }
  }

  dynamic "logs" {
    for_each = var.logs != null ? [var.logs] : []
    content {
      detailed_error_messages = logs.value.detailed_error_messages
      failed_request_tracing  = logs.value.failed_request_tracing

      dynamic "application_logs" {
        for_each = try(logs.value.application_logs, null) != null ? [logs.value.application_logs] : []
        content {
          file_system_level = application_logs.value.file_system_level
        }
      }

      dynamic "http_logs" {
        for_each = try(logs.value.http_logs, null) != null ? [logs.value.http_logs] : []
        content {
          file_system {
            retention_in_days = http_logs.value.retention_in_days
            retention_in_mb   = http_logs.value.retention_in_mb
          }
        }
      }
    }
  }

  app_settings = merge(
    var.app_settings,
    var.startup_command != "" ? {
      WEBSITES_CONTAINER_START_TIME = var.startup_command
    } : {}
  )

  identity {
    type = "SystemAssigned"
  }

  tags = var.tags
}

# =============================================================================
# App Service Slot
# =============================================================================

resource "azurerm_linux_web_app_slot" "this" {
  name                          = var.slot_name
  app_service_id                = azurerm_linux_web_app.this.id
  enabled                       = true
  client_affinity_enabled       = false
  client_certificate_enabled    = false
  client_certificate_mode       = "Required"
  https_only                    = var.https_only
  public_network_access_enabled = true

  site_config {
    always_on                         = var.always_on
    ftps_state                        = "Disabled"
    http2_enabled                     = true
    health_check_path                 = local.effective_slot_health_check
    health_check_eviction_time_in_min = 2
    ip_restriction_default_action     = "Allow"
    load_balancing_mode               = "LeastRequests"
    minimum_tls_version               = "1.2"
    scm_ip_restriction_default_action = "Allow"
    scm_minimum_tls_version           = "1.2"
    scm_use_main_ip_restriction       = false
    use_32_bit_worker                 = true
    websockets_enabled                = false
    worker_count                      = 1

    dynamic "application_stack" {
      for_each = local.effective_slot_docker_image != "" ? [1] : []
      content {
        docker_image_name        = local.effective_slot_docker_image
        docker_registry_url      = var.acr_login_server != "" ? "https://${var.acr_login_server}" : null
        docker_registry_username = var.slot_docker_registry_username
        docker_registry_password = var.slot_docker_registry_password
      }
    }
  }

  dynamic "logs" {
    for_each = var.slot_logs != null ? [var.slot_logs] : []
    content {
      detailed_error_messages = logs.value.detailed_error_messages
      failed_request_tracing  = logs.value.failed_request_tracing

      dynamic "application_logs" {
        for_each = try(logs.value.application_logs, null) != null ? [logs.value.application_logs] : []
        content {
          file_system_level = application_logs.value.file_system_level
        }
      }

      dynamic "http_logs" {
        for_each = try(logs.value.http_logs, null) != null ? [logs.value.http_logs] : []
        content {
          file_system {
            retention_in_days = http_logs.value.retention_in_days
            retention_in_mb   = http_logs.value.retention_in_mb
          }
        }
      }
    }
  }

  app_settings = var.slot_app_settings

  identity {
    type = "SystemAssigned"
  }

  tags = var.tags
}

# =============================================================================
# ACR Pull Role Assignment (Main App)
# =============================================================================

resource "azurerm_role_assignment" "acr_pull" {
  count                = var.enable_acr_pull_role_assignment ? 1 : 0
  scope                = var.acr_resource_id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_linux_web_app.this.identity[0].principal_id
}

# =============================================================================
# ACR Pull Role Assignment (Slot)
# =============================================================================

resource "azurerm_role_assignment" "acr_pull_slot" {
  count                = var.enable_slot_acr_pull_role_assignment ? 1 : 0
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

output "custom_domain_verification_id" {
  value = azurerm_linux_web_app.this.custom_domain_verification_id
}

output "principal_id" {
  value = azurerm_linux_web_app.this.identity[0].principal_id
}

output "service_plan_id" {
  value = local.effective_service_plan_id
}

output "slot_id" {
  value = azurerm_linux_web_app_slot.this.id
}

output "slot_name" {
  value = var.slot_name
}
