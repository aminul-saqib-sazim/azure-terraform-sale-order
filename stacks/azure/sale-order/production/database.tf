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
