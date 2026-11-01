# Obtener informacion de la cuenta AWS
data "aws_caller_identity" "current" {}


# Modulo de red
module "network" {
  source = "../../modules/network"

  environment = var.environment
  vpc_cidr    = var.vpc_cidr
}


# Modulo de almacenamiento
module "storage" {
  source = "../../modules/storage"

  environment      = var.environment
  data_bucket_name = coalesce(var.data_bucket_name, "coderhouse-data-${data.aws_caller_identity.current.account_id}")
}


# Modulo de identidad
module "identity" {
  source = "../../modules/identity"

  environment = var.environment

  data_bucket_name = module.storage.data_bucket_name
  data_prefix      = "raw/"
}
