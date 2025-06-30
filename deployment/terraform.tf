terraform {
  required_version = "~> 1.12"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "= 5.100.0"
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

# Local values with fallbacks for when EKS state is not available
locals {
  # Try to get values from EKS state, fallback to variables if not available
  aws_region_from_eks = try(data.terraform_remote_state.eks.outputs.aws_region, null)
  cluster_name_from_eks = try(data.terraform_remote_state.eks.outputs.cluster_name, null)
  domain_name_from_eks = try(data.terraform_remote_state.eks.outputs.domain_name, null)

  # Use EKS values if available, otherwise fallback to variables
  aws_region = local.aws_region_from_eks != null ? local.aws_region_from_eks : var.aws_region
  cluster_name = local.cluster_name_from_eks != null ? local.cluster_name_from_eks : "aws-patterns-edc"
  domain_name = local.domain_name_from_eks != null ? local.domain_name_from_eks : var.domain_name
}

provider "aws" {
  region = local.aws_region
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
  name = local.cluster_name
}

data "aws_eks_cluster_auth" "eks_cluster_auth_d" {
  name = local.cluster_name
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
