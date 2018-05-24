provider "aws" {
  region = "us-east-1"
}

terraform {
  backend "s3" {
    bucket = "terraform-state-jmf"
    key    = "github.com/ferdegje/cqrs/terraform.tfstate"
    region = "eu-west-2"
  }
}

module "fargate" {
  source = "./fargate"
}
