# Outputs del modulo Network

output "vpc_id" {
  description = "ID de la VPC del entorno DEV"
  value       = module.network.vpc_id
}

output "private_subnet_ids" {
  description = "IDs de las subredes privadas del entorno DEV"
  value       = module.network.private_subnet_ids
}


# Outputs del modulo Identity

output "data_execution_role_arn" {
  description = "ARN del rol de ejecucion de datos"
  value       = module.identity.data_execution_role_arn
}

output "audit_role_arn" {
  description = "ARN del rol de auditoria"
  value       = module.identity.audit_role_arn
}


# Outputs del modulo Storage

output "data_bucket_name" {
  description = "Nombre del bucket S3 de datos del entorno DEV"
  value       = module.storage.data_bucket_name
}

output "data_bucket_arn" {
  description = "ARN del bucket S3 de datos del entorno DEV"
  value       = module.storage.data_bucket_arn
}

output "data_bucket_id" {
  description = "ID del bucket S3 de datos del entorno DEV"
  value       = module.storage.data_bucket_id
}
