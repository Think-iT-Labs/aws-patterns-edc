########################################
# Global Configuration Outputs
########################################

output "aws_region" {
  description = "AWS region where resources are deployed"
  value       = var.aws_region
}

output "project_name" {
  description = "Name of the project"
  value       = var.project_name
}

output "domain_name" {
  description = "Domain name for exposing cluster resources"
  value       = var.domain_name
}

########################################
# VPC and Networking Outputs
########################################

output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "vpc_cidr_block" {
  description = "CIDR block of the VPC"
  value       = aws_vpc.main.cidr_block
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = [for subnet in aws_subnet.private_zone : subnet.id]
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = [for subnet in aws_subnet.public_zone : subnet.id]
}

output "availability_zones" {
  description = "Availability zones used"
  value       = var.eks_availability_zones
}

########################################
# EKS Cluster Outputs
########################################

output "cluster_name" {
  description = "Name of the EKS cluster"
  value       = aws_eks_cluster.eks_cluster.name
}

output "cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = aws_eks_cluster.eks_cluster.endpoint
}

output "cluster_version" {
  description = "The Kubernetes version for the EKS cluster"
  value       = aws_eks_cluster.eks_cluster.version
}

output "cluster_arn" {
  description = "The Amazon Resource Name (ARN) of the cluster"
  value       = aws_eks_cluster.eks_cluster.arn
}

########################################
# EKS Node Group Outputs
########################################

output "node_group_status" {
  description = "Status of the EKS Node Group"
  value       = aws_eks_node_group.eks_worker_nodes.status
}

########################################
# kubectl Configuration Command
########################################

output "kubectl_config_command" {
  description = "Command to configure kubectl for this cluster"
  value       = "aws eks update-kubeconfig --name ${aws_eks_cluster.eks_cluster.name} --region ${var.aws_region}"
}

########################################
# Important URLs and Endpoints
########################################

output "cluster_console_url" {
  description = "AWS Console URL for the EKS cluster"
  value       = "https://${var.aws_region}.console.aws.amazon.com/eks/home?region=${var.aws_region}#/clusters/${aws_eks_cluster.eks_cluster.name}"
}

output "expected_endpoints" {
  description = "Expected endpoints after data space deployment"
  value = {
    issuer_endpoint    = "https://issuer.${var.domain_name}"
    bdrs_endpoint      = "https://bdrs.${var.domain_name}"
    companyx_endpoint  = "https://companyx.${var.domain_name}"
    companyy_endpoint  = "https://companyy.${var.domain_name}"
  }
}

########################################
# Next Steps Information
########################################

output "next_steps" {
  description = "Next steps after EKS cluster deployment"
  value = [
    "1. Configure kubectl: aws eks update-kubeconfig --name ${aws_eks_cluster.eks_cluster.name} --region ${var.aws_region}",
    "2. Verify cluster: kubectl get nodes",
    "3. Generate DID resources using the Python script",
    "4. Apply Terraform to deploy data space components from deployment/ directory",
  ]
}

########################################
# Data Sources for Token
########################################

data "aws_eks_cluster_auth" "cluster" {
  name = aws_eks_cluster.eks_cluster.name
}
