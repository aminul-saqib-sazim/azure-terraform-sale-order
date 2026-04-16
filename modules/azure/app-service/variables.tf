variable "location" {
  description = "Azure location"
  type        = string
}

variable "resource_group_name" {
  description = "Resource group name"
  type        = string
}

variable "service_plan_id" {
  description = "Service Plan ID (required)"
  type        = string
}

variable "app_name" {
  description = "Name of the web app"
  type        = string
}

variable "docker_image_name" {
  description = "Docker image name (e.g., sale-order-backend)"
  type        = string
  default     = ""
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

variable "startup_command" {
  description = "Startup command (e.g., yarn start:prod)"
  type        = string
  default     = ""
}

variable "slot_name" {
  description = "Slot name (e.g., production, staging)"
  type        = string
  default     = "production"
}

variable "acr_resource_id" {
  description = "ACR resource ID for role assignment"
  type        = string
  default     = ""
}

variable "acr_login_server" {
  description = "ACR login server (e.g., salescontractapp.azurecr.io)"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags for resources"
  type        = map(string)
  default     = {}
}
