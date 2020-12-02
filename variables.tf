variable "region" {}

variable "ami_name" {}

variable "ami_id" {}

variable "vpc-cidr" {}

variable "subnet-cidr-public" {}

variable "subnet-cidr-public2" {}

# for the purpose of this exercise use the default key pair on your local system
variable "public_key" {
  default = "~/.ssh/id_rsa.pub"
}

