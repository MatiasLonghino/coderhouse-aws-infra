variable "environment" {
  description = "Nombre del entorno de despliegue"
  type        = string
}

variable "data_bucket_name" {
  description = "Nombre globalmente unico del bucket S3 de datos"
  type        = string
  nullable    = false
}
