output "data_execution_role_arn" {
  description = "ARN del rol IAM de ejecucion de datos"
  value       = aws_iam_role.data_execution.arn
}

output "audit_role_arn" {
  description = "ARN del rol IAM de auditoria"
  value       = aws_iam_role.audit.arn
}