provider "aws" {
  region = var.region

  default_tags {
    tags = {
      Owner       = "Junior"
      ManagedBy   = "Terraform"
      Environment = "dev"
      Project     = "EKS"
    }
  }

}
