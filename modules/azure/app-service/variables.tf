variable "name" {
  description = "Name of the service plan"
  type        = string
}

variable "service_plan_id" {
  description = "Existing App Service Plan ID to reuse"
  type        = string
  default     = null
  nullable    = true
}

variable "create_service_plan" {
  description = "Create a new App Service Plan instead of reusing an existing one"
  type        = bool
  default     = true
}

variable "location" {
  description = "Azure location"
  type        = string
}

variable "resource_group_name" {
  description = "Resource group name"
  type        = string
}

variable "sku_name" {
  description = "SKU name for App Service Plan"
  type        = string
  default     = "S1"
}

variable "app_name" {
  description = "Name of the web app"
  type        = string
}

variable "docker_image_name" {
  description = "Docker image name"
  type        = string
  default     = ""
}

variable "docker_registry_username" {
  description = "Container registry username for the main app"
  type        = string
  default     = null
  nullable    = true
}

variable "docker_registry_password" {
  description = "Container registry password for the main app"
  type        = string
  default     = null
  nullable    = true
  sensitive   = true
}

variable "slot_docker_image_name" {
  description = "Docker image name for the slot. Set to an empty string to leave the slot image unset."
  type        = string
  default     = null
  nullable    = true
}

variable "slot_docker_registry_username" {
  description = "Container registry username for the slot"
  type        = string
  default     = null
  nullable    = true
}

variable "slot_docker_registry_password" {
  description = "Container registry password for the slot"
  type        = string
  default     = null
  nullable    = true
  sensitive   = true
}

variable "docker_image_tag" {
  description = "Docker image tag"
  type        = string
  default     = "latest"
}

variable "health_check_path" {
  description = "Health check path"
  type        = string
  default     = "/api/v1/health"
}

variable "slot_health_check_path" {
  description = "Health check path for the slot"
  type        = string
  default     = null
  nullable    = true
}

variable "startup_command" {
  description = "Startup command"
  type        = string
  default     = ""
}

variable "app_settings" {
  description = "Application settings for the main app"
  type        = map(string)
  default     = {}
}

variable "slot_app_settings" {
  description = "Application settings for the slot"
  type        = map(string)
  default     = {}
}

variable "logs" {
  description = "Log configuration for the main app"
  type = object({
    detailed_error_messages = bool
    failed_request_tracing  = bool
    application_logs = optional(object({
      file_system_level = string
    }))
    http_logs = optional(object({
      retention_in_days = number
      retention_in_mb   = number
    }))
  })
  default  = null
  nullable = true
}

variable "slot_logs" {
  description = "Log configuration for the slot"
  type = object({
    detailed_error_messages = bool
    failed_request_tracing  = bool
    application_logs = optional(object({
      file_system_level = string
    }))
    http_logs = optional(object({
      retention_in_days = number
      retention_in_mb   = number
    }))
  })
  default  = null
  nullable = true
}

variable "https_only" {
  description = "Enable HTTPS-only traffic"
  type        = bool
  default     = false
}

variable "always_on" {
  description = "Keep the app always on"
  type        = bool
  default     = true
}

variable "slot_name" {
  description = "Slot name"
  type        = string
  default     = "staging"
}

variable "acr_resource_id" {
  description = "ACR resource ID for role assignment"
  type        = string
  default     = ""
}

variable "acr_login_server" {
  description = "ACR login server"
  type        = string
  default     = ""
}

variable "enable_acr_pull_role_assignment" {
  description = "Create an AcrPull role assignment for the main app identity"
  type        = bool
  default     = true
}

variable "enable_slot_acr_pull_role_assignment" {
  description = "Create an AcrPull role assignment for the slot identity"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags for resources"
  type        = map(string)
  default     = {}
}
