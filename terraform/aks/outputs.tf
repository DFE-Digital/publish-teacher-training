#test
output "server_docker_image" {
  value = module.postgres.server_docker_image
}

output "server_database_type" {
  value = module.postgres.server_database_type
}

output "azure_extensions" {
  value = module.postgres.azure_extensions
}

output "server_postgis_version" {
  value = module.postgres.server_postgis_version
}
