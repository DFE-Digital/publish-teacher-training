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
variable "postgres_create_servicename_db" {
  type    = string
  default = "value"
}

variable "db_sslmode" {
  type    = string
  default = "value"
}

variable "env_config" {
  type    = string
  default = "value"
}

variable "postgres_extensions" {
  type    = string
  default = "value"
}

variable "app_config_file" {
  type    = string
  default = "./workspace_variables/app_config.yml"
}
