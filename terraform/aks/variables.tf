variable "app_environment" {
  type = string
}

variable "app_name" {
  type    = string
  default = null
}

variable "azure_resource_prefix" {
  type = string
}

variable "cluster" {
  type = string
}

variable "config_short" {
  type = string
}

variable "deploy_azure_backing_services" {
  type    = string
  default = true
}

variable "docker_image" {
  type = string
}

variable "enable_find" {
  type    = bool
  default = true
}

variable "enable_monitoring" {
  type    = bool
  default = true
}

variable "enable_logit" { default = false }

variable "statuscake_contact_groups" {
  type        = list(number)
  default     = []
  description = "Contact group IDs for receiving StatusCake alerts"
}

variable "alert_window_size" {
  default = "PT5M"
}

variable "send_traffic_to_maintenance_page" {
  default     = false
  description = "During a maintenance operation, keep sending traffic to the maintenance page instead of resetting the ingress"
}

variable "namespace" {
  type = string
}

variable "service_short" {
  type = string
}

variable "service_name" {
  type = string
}

variable "key_vault_name" {
  type = string
}

variable "key_vault_app_secret_name" {
  type = string
}

variable "key_vault_infra_secret_name" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "postgres_version" { default = 13 }

variable "postgres_enable_high_availability" { default = false }

variable "postgres_flexible_server_sku" { default = "B_Standard_B1ms" }

variable "app_config_file" {
  type    = string
  default = "./workspace_variables/app_config.yml"
}

variable "additional_hostnames" {
  default = []
  type    = list(any)
}

variable "worker_apps" {
  type = map(
    object({
      startup_command = optional(list(string), [])
      probe_command   = optional(list(string), [])
      replicas        = optional(number, 1)
      max_memory      = optional(string, "512Mi")
    })
  )
  default = {}
}

variable "main_app" {
  type = map(
    object({
      startup_command = optional(list(string), [])
      probe_path      = optional(string, null)
      replicas        = optional(number, 1)
      max_memory      = optional(string, "1Gi")
    })
  )
  default = {}
}

variable "use_db_setup_command" {
  type        = bool
  default     = false
  description = "Where to set the startup command of the web app to use db:setup. Set to true for first deployment to an environment"
}

variable "postgres_azure_maintenance_window" { default = null }

variable "apex_urls" {
  description = "List of URLs with DNS zones apex domain for SSL certificate monitoring"
  type        = list(string)
  default     = []
}

variable "enable_sanitised_storage" {
  description = "Enable sanitised storage account"
  type        = bool
  default     = false
}

variable "uploads_storage_account_name" {
  type    = string
  default = null
}