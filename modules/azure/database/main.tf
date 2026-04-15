# =============================================================================
# PostgreSQL Flexible Server
# =============================================================================

resource "azurerm_postgresql_flexible_server" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location

  version    = var.pg_version
  sku_name   = var.sku_name
  storage_mb = var.storage_mb

  administrator_login    = var.admin_username
  administrator_password = var.admin_password

  public_network_access_enabled = var.public_network_access_enabled

  backup_retention_days = var.backup_retention_days

  tags = var.tags
}

resource "azurerm_postgresql_flexible_server_database" "this" {
  name      = var.database_name
  server_id = azurerm_postgresql_flexible_server.this.id
  collation = "en_US.utf8"
  charset   = "UTF8"
}

resource "azurerm_postgresql_flexible_server_firewall_rule" "this" {
  name             = var.firewall_rule_name
  server_id        = azurerm_postgresql_flexible_server.this.id
  start_ip_address = var.start_ip
  end_ip_address   = var.end_ip
}

resource "azurerm_postgresql_flexible_server_firewall_rule" "azure_services" {
  name             = "AllowAzureServices"
  server_id        = azurerm_postgresql_flexible_server.this.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}

# =============================================================================
# Outputs
# =============================================================================

output "id" {
  value = azurerm_postgresql_flexible_server.this.id
}

output "name" {
  value = azurerm_postgresql_flexible_server.this.name
}

output "fqdn" {
  value = azurerm_postgresql_flexible_server.this.fqdn
}

output "connection_string" {
  value     = "postgresql://${var.admin_username}:${var.admin_password}@${azurerm_postgresql_flexible_server.this.fqdn}:5432/${var.database_name}?sslmode=require"
  sensitive = true
}
