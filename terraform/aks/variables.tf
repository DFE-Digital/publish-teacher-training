variable "app_environment" {
  type = string
}

variable "app_suffix" {
  type    = string
  default = ""
}

variable "azure_resource_prefix" {
  type = string
}

variable "azure_sp_credentials_json" {
  type    = string
  default = null
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

# Below added to silence warnings
variable "db_sslmode" {
  type    = string
  default = "value"
}

variable "env_config" {
  type    = string
  default = "value"
}

variable "postgres_version" { default = 13 }

variable "app_config_file" {
  type    = string
  default = "./workspace_variables/app_config.yml"
}

variable "gov_uk_host_names" {
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
  type    = bool
  default = false
}
