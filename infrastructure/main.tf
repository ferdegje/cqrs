provider "aws" {
  region = "us-east-1"
}

module "fargate" {
  source = "./fargate"
}
