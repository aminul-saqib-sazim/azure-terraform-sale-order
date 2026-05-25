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
