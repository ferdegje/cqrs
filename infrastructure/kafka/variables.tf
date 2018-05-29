variable "aws_vpc" {
  description = "id of the VPC where resources should be placed"
  default = ""
}

variable "aws_subnet" {
  description = "The subnet in which the Kafka infrastructure should be built"
  default     = ""
}
