##############################################
# Global configuration
##############################################

variable "aws_region" {
  type        = string
  description = "AWS region to deploy to"
}

variable "project_name" {
  type        = string
  description = "Name of the project"
}

variable "domain_name" {
  type        = string
  description = "Domain name for exposing the cluster resources"
}

##############################################
# EKS configuration
##############################################

variable "vpc_name" {
  description = "VPC name"
  type        = string
  default     = "main"
}

variable "vpc_cidr_block" {
  description = "The CIDR block to use for the vpc"
  type        = string
}

variable "subnet_cidr_blocks" {
  description = "List of CIDR blocks to use for subnets"
  type        = list(string)
}

##############################################
# EKS configuration
##############################################
variable "eks_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "eks-cluster"
}

variable "eks_version" {
  description = "Kubernetes version for EKS"
  type        = string
  default     = "1.33"
}

variable "eks_availability_zones" {
  description = "List of availability zones in the region where the EKS nodes will be deployed"
  type        = list(string)
}

variable "eks_endpoint_private_access" {
  description = "Enable private access to the EKS endpoint"
  type        = bool
  default     = false
}

variable "eks_endpoint_public_access" {
  description = "Enable public access to the EKS endpoint"
  type        = bool
  default     = true
}

variable "eks_authentication_mode" {
  description = "Authentication mode for EKS access configuration"
  type        = string
}

variable "eks_bootstrap_cluster_creator_admin_permissions" {
  description = "Enable admin permissions for the EKS cluster creator"
  type        = bool
  default     = true
}

variable "eks_node_group_name" {
  description = "The name of the EKS node group"
  type        = string
}

variable "eks_node_ec2_capacity_type" {
  description = "The capacity type for eks worker nodes ec2 instances"
  type        = string
  default     = "ON_DEMAND"
}

variable "eks_node_ec2_instance_types" {
  description = "List of eks worker nodes ec2 instances types"
  type        = list(string)
}

variable "eks_node_scaling_config" {
  description = "Scaling configuration for the cluster"
  type = object({
    desired_size = number
    max_size     = number
    min_size     = number
  })
}

variable "eks_secret_name_prefix" {
  description = "The prefix for EKS-related secret names"
  type        = string
  default     = "eks-"
}

##############################################
# EKS Add-on versions
##############################################

variable "metrics_server_chart_version" {
  type        = string
  description = "Version of the Metrics Server Helm chart"
}

variable "pod_identity_addon_version" {
  type        = string
  description = "Version of the EKS Pod Identity Addon"
}

variable "aws_lbc_chart_version" {
  type        = string
  description = "Version of the AWS Load Balancer Controller Helm chart"
}

variable "aws_ebs_csi_driver_addon_version" {
  type        = string
  description = "Version of the EKS EBS CSI Driver Addon"
}

variable "external_dns_chart_version" {
  type        = string
  description = "Version of the External DNS Helm chart"
}

variable "external_secrets_chart_version" {
  description = "Version of the External Secrets Helm chart to deploy"
  type        = string
}

