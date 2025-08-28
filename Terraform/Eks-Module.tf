module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version #"1.27" # opcional: escolha a versão que deseja suportar

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = false

  # Recomendo criar OIDC para usar IRSA (ServiceAccount -> IAM)
  #create_oidc = true Descontinuado, agora é padrão criar OIDC
  enable_irsa = true

  # Garante que o usuário/role que cria o cluster tenha permissões de administrador
  enable_cluster_creator_admin_permissions = true

  cluster_addons = {
    amazon-cloudwatch-observability = {}
  }

  # Managed Node Group com 3 nós
  eks_managed_node_groups = {
    default_nodes = {
      instance_types = ["t3.medium"]
      desired_size   = var.desired_capacity
      min_size       = 3
      max_size       = 5
      capacity_type  = "ON_DEMAND"

      iam_role_additional_policies = {
        CloudWatchAgentServerPolicy = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
      }

      # O acesso SSH aos nós não foi configurado.
      # Para habilitar, crie um par de chaves EC2 na AWS e adicione o argumento abaixo:
      # key_name = "nome-da-sua-chave-na-aws"
    }
  }

  tags = {
    Environment = "dev"
    Project     = "EKS-academico"
  }
}
