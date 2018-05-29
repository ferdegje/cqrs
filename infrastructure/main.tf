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

  name = "CQRS"
  aws_vpc = "${module.base_vpc.vpc_id}"
  aws_subnets = "${module.base_vpc.public_subnets}"
}

data "aws_availability_zones" "available" {}

locals {
  cidr = "10.0.0.0/16"
}

module "base_vpc" {
  source = "github.com/terraform-aws-modules/terraform-aws-vpc"

  name = "CQRS"
  cidr = "${local.cidr}"

  azs             = ["${data.aws_availability_zones.available.names[0]}", "${data.aws_availability_zones.available.names[1]}"]
  private_subnets = []
  public_subnets  = ["${cidrsubnet(local.cidr, 4, 3)}", "${cidrsubnet(local.cidr, 4, 4)}"]

  enable_nat_gateway = false
  single_nat_gateway = false
}

module "kafka" {
  source = "./kafka"

  aws_vpc = "${module.base_vpc.vpc_id}"
  aws_subnet = "${module.base_vpc.public_subnets[0]}"
}
