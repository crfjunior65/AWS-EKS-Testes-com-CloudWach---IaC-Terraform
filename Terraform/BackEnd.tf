terraform {
  backend "s3" {
    bucket         = "crfjunior-tfstate-bucket" # altere para o nome do seu bucket
    key            = "eks/terraform.tfstate"
    region         = "us-east-1"           # ajuste para sua região
    dynamodb_table = "terraform-locks-eks" # altere se tiver outro nome
    encrypt        = true
  }
}
