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
