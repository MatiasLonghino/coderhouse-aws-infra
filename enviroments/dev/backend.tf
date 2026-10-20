terraform {
  backend "s3" {
    bucket         = "coderhouse-tfstate-925213028629"
    key            = "dev/terraform.tfstate"
    region         = "us-east-2"
    encrypt        = true
    dynamodb_table = "coderhouse-tf-lock"
    profile        = "coder-terraform-tf"
  }
}