variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "cluster_name" {
  description = "Nome do cluster EKS"
  type        = string
  default     = "plataforma-bet-eks-cluster"
}

variable "cluster_version" {
  description = "Versão do Kubernetes"
  type        = string
  default     = "1.29"
}

variable "desired_capacity" {
  description = "Número de nós desejados"
  type        = number
  default     = 3
}

variable "key_name" {
  description = "Par de chaves EC2 para SSH (opcional)"
  type        = string
  default     = "aws-key-terraform"
}
