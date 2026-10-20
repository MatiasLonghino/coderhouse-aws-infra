variable "environment" {
  description = "Nombre del entorno de despliegue"
  type        = string
}

variable "data_bucket_name" {
  description = "Nombre del bucket S3 de datos"
  type        = string
}

variable "data_prefix" {
  description = "Prefijo de S3 al que se permitira acceder"
  type        = string
  default     = "raw/"
}