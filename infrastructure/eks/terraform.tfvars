# Global configuration
aws_region                                      = "us-east-1"
project_name                                    = "aws-patterns-edc"
domain_name                                     = "oaebudt.think-it.io"

# VPC configuration
vpc_name                                        = "aws-patterns-edc"
vpc_cidr_block                                  = "10.0.0.0/16"
subnet_cidr_blocks                              = ["10.0.0.0/20", "10.0.16.0/20", "10.0.32.0/20", "10.0.48.0/20"]

# EKS configuration
eks_name                                        = "aws-patterns-edc"
eks_version                                     = "1.33"
eks_availability_zones                          = ["us-east-1a", "us-east-1b"]
eks_endpoint_private_access                     = false
eks_endpoint_public_access                      = true
eks_authentication_mode                         = "API"
eks_bootstrap_cluster_creator_admin_permissions = true
eks_node_group_name                             = "general-purpose"
eks_node_ec2_capacity_type                      = "ON_DEMAND"
eks_node_ec2_instance_types                     = ["t3.medium"]
eks_node_scaling_config = {
  desired_size = 2
  max_size     = 2
  min_size     = 2
}
eks_secret_name_prefix           = "aws-patterns-edc"

# EKS Add-on versions
metrics_server_chart_version     = "3.12.1"
pod_identity_addon_version       = "v1.3.7-eksbuild.2"
aws_lbc_chart_version            = "1.13.1"
aws_ebs_csi_driver_addon_version = "v1.44.0-eksbuild.1"
external_dns_chart_version       = "1.16.0"
external_secrets_chart_version   = "0.16.2"


