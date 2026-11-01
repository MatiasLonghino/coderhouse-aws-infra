variable "environment" {
  description = "Nombre del entorno de despliegue"
  type        = string
  default     = "dev"
}

variable "aws_region" {
  description = "Region de AWS"
  type        = string
  default     = "us-east-2"
}

variable "vpc_cidr" {
  description = "Rango de direcciones IP de la VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "data_bucket_name" {
  description = "Nombre opcional del bucket S3 de datos; por defecto se usa coderhouse-data-<account_id>"
  type        = string
  default     = null
}
