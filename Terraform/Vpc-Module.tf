data "aws_availability_zones" "available" {}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.8"

  name = "${var.cluster_name}-vpc"
  cidr = "10.50.0.0/16"

  #azs             = slice(data.aws_availability_zones.available.names, 0, 3)
  azs             = ["${var.region}a", "${var.region}b", "${var.region}c"]
  public_subnets  = ["10.50.1.0/24", "10.50.2.0/24", "10.50.3.0/24"]
  private_subnets = ["10.50.11.0/24", "10.50.12.0/24", "10.50.13.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = false
}
