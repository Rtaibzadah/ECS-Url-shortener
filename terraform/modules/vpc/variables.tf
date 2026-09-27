variable "common_tags" {
  type = map(string)
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "private_subnet_cidr" {
  type = map(string)
  #map: "key" = "value"
  default = {
    "eu-west-2a" = "10.0.1.0/24"
    "eu-west-2b" = "10.0.2.0/24"
  }
}

variable "public_subnet_cidr" {
  type = map(string)
  default = {
    "eu-west-2a" = "10.0.3.0/24"
    "eu-west-2b" = "10.0.4.0/24"
  }
}

variable "vpc_endpoints_sg" {
  type = string
}

variable "region" {
  type    = string
  default = "eu-west-2"
}
