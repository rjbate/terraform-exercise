variable "region" {}

variable "vpc-cidr" {}

variable "subnet-cidr-public" {}

# for the purpose of this exercise use the default key pair on your local system
variable "public_key" {
  default = "~/.ssh/id_rsa.pub"
}
