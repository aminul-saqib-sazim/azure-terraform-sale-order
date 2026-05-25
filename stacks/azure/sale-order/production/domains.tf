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
