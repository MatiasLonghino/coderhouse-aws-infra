output "data_bucket_name" {
  description = "Nombre del bucket S3 de datos"
  value       = aws_s3_bucket.data.bucket
}

output "data_bucket_arn" {
  description = "ARN del bucket S3 de datos"
  value       = aws_s3_bucket.data.arn
}

output "data_bucket_id" {
  description = "ID del bucket S3 de datos (coincide con su nombre)"
  value       = aws_s3_bucket.data.id
}
