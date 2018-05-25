variable "name" {
  description = "Name to be used on all the resources as identifier"
  default     = ""
}

variable "tags" {
  description = "A map of tags to add to all resources"
  default     = {}
}

variable "aws_vpc" {
  description = "id of the VPC where resources should be placed"
  default = ""
}

variable "aws_subnets" {
  description = "Subnets in which the resources should be placed"
  default = []
}
