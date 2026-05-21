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
