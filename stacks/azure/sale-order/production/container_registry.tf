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
