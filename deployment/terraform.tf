terraform {
  required_version = "1.12.2"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.100.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.17.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.37.1"
    }
  }

  backend "local" {
    path = "terraform.tfstate"
  }
}

# Data source to read EKS infrastructure state
data "terraform_remote_state" "eks" {
  backend = "local"
  config = {
    path = "../infrastructure/eks/terraform.tfstate"
  }
}

provider "aws" {
  region = data.terraform_remote_state.eks.outputs.aws_region
  default_tags {
    tags = {
      Project   = var.project_name
      GitRepo   = "https://github.com/Think-iT-Labs/aws-patterns-edc"
      Cluster   = "aws-patterns-edc"
      ManagedBy = "terraform"
    }
  }
}

data "aws_eks_cluster" "eks_cluster_d" {
  name = data.terraform_remote_state.eks.outputs.cluster_name
}

data "aws_eks_cluster_auth" "eks_cluster_auth_d" {
  name = data.terraform_remote_state.eks.outputs.cluster_name
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.eks_cluster_d.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks_cluster_d.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.eks_cluster_auth_d.token
  }
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.eks_cluster_d.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks_cluster_d.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.eks_cluster_auth_d.token
}
