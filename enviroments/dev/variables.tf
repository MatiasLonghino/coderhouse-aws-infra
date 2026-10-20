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