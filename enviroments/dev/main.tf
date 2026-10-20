# Obtener informacion de la cuenta AWS
data "aws_caller_identity" "current" {}


# Modulo de red
module "network" {
  source = "../../modules/network"

  environment = var.environment
  vpc_cidr    = var.vpc_cidr
}


# Modulo de identidad
module "identity" {
  source = "../../modules/identity"

  environment = var.environment

  data_bucket_name = "coderhouse-data-${data.aws_caller_identity.current.account_id}"
  data_prefix      = "raw/"
}
