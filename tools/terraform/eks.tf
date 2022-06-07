module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "18.23.0"

  create = var.eks_enabled

  cluster_name    = local.eks_cluster_name
  cluster_version = var.eks_version

  cluster_ip_family = "ipv4"
  // create_cni_ipv6_iam_policy = true

  enable_irsa = true

  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true

  cluster_addons = {
    coredns = {
      resolve_conflicts = "OVERWRITE"
    }
    kube-proxy = {}
    vpc-cni    = {
      resolve_conflicts = "OVERWRITE"
    }
  }

  cluster_encryption_config = [
    {
      provider_key_arn = aws_kms_key.eks.arn
      resources        = ["secrets"]
    }
  ]

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  # Extend cluster security group rules
  cluster_security_group_additional_rules = {
    egress_nodes_ephemeral_ports_tcp = {
      description                = "To node 1025-65535"
      protocol                   = "tcp"
      from_port                  = 0
      to_port                    = 65535
      type                       = "egress"
      source_node_security_group = true
    }
  }

  # Extend node-to-node security group rules
  node_security_group_additional_rules = {
    ingress_self_all = {
      description = "Node to node all ports/protocols"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "ingress"
      self        = true
    }
    egress_all = {
      description      = "Node all egress"
      protocol         = "-1"
      from_port        = 0
      to_port          = 0
      type             = "egress"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }
  }

  eks_managed_node_group_defaults = {
    iam_role_attach_cni_policy = true
  }

  eks_managed_node_groups = {
    initial = {
      capacity_type = "ON_DEMAND"
      instance_types = [var.eks_node_instance_type]

      min_size     = 1
      max_size     = 3
      desired_size = 1

      labels         = {
        Environment = var.prefix
        GithubRepo  = "terraform-aws-eks"
        GithubOrg   = "terraform-aws-modules"
      }

    }
  }

  tags = {
    Environment = var.prefix
    GithubRepo  = "terraform-aws-eks"
    GithubOrg   = "terraform-aws-modules"
  }

  manage_aws_auth_configmap = true

  aws_auth_roles    = local.aws_auth_roles

}

resource "aws_iam_role" "admin_role" {
  name               = "${var.prefix}-eks-admin-${var.name}"
  tags               = local.tags
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
  POLICY
}

resource "aws_kms_key" "eks" {
  description             = "EKS Secret Encryption Key"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  tags = local.tags
}

resource "aws_security_group" "additional" {
  count       = var.eks_enabled ? 1 : 0
  name_prefix = "${var.prefix}-additional"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = [
      "10.0.0.0/8",
      "172.16.0.0/12",
      "192.168.0.0/16",
    ]
  }

  tags = local.tags
}

module "cluster-autoscaler" {
  source = "./cluster-autoscaler"
  create = var.eks_enabled
  aws_region = var.aws_region
  prefix = var.prefix
  eks_cluster_id = module.eks.cluster_id
  eks_cluster_version = module.eks.cluster_version
  eks_cluster_oidc_issuer_url = module.eks.cluster_oidc_issuer_url
  depends_on = [
    module.eks
  ]
}

module "aws-load-balancer-controller" {
  source = "./aws-load-balancer-controller"
  create = var.eks_enabled
  aws_region = var.aws_region
  vpc_id = module.vpc.vpc_id
  prefix = var.prefix
  eks_cluster_id = module.eks.cluster_id
  eks_cluster_version = module.eks.cluster_version
  eks_cluster_oidc_issuer_url = module.eks.cluster_oidc_issuer_url
  depends_on = [
    module.eks
  ]
}

module "app" {
  source = "./app"
  create = var.eks_enabled
  prefix = var.prefix
  eks_cluster_id = module.eks.cluster_id
  eks_cluster_version = module.eks.cluster_version
  eks_cluster_oidc_issuer_url = module.eks.cluster_oidc_issuer_url
  depends_on = [
    module.eks
  ]
}