########################################
# Data Space Endpoints
########################################

output "bdrs_url" {
  description = "BPN-DID Resolution Service endpoint URL"
  value       = "https://bdrs.${local.domain_name}"
}

output "issuer_url" {
  description = "DID Issuer endpoint URL"
  value       = "https://issuer.${local.domain_name}"
}

output "companyx_connector_url" {
  description = "Company X EDC connector endpoint URL"
  value       = "https://companyx.${local.domain_name}"
}

output "companyy_connector_url" {
  description = "Company Y EDC connector endpoint URL"
  value       = "https://companyy.${local.domain_name}"
}

########################################
# Identity Hub API Keys
########################################

output "companyx_ih_superuser_apikey" {
  description = "Company X Identity Hub super-user API key"
  value       = module.companyx_tx-identity-hub.ih_superuser_apikey
  sensitive   = true
}

output "companyy_ih_superuser_apikey" {
  description = "Company Y Identity Hub super-user API key"
  value       = module.companyy_tx-identity-hub.ih_superuser_apikey
  sensitive   = true
}

########################################
# Configuration Information
########################################

output "domain_name" {
  description = "Domain name used for all endpoints"
  value       = local.domain_name
}

output "aws_region" {
  description = "AWS region where data space is deployed"
  value       = data.terraform_remote_state.eks.outputs.aws_region
}

output "cluster_name" {
  description = "EKS cluster name hosting the data space"
  value       = data.terraform_remote_state.eks.outputs.cluster_name
}

########################################
# Business Partner Numbers (BPNs)
########################################

output "companyx_bpn" {
  description = "Company X Business Partner Number"
  value       = var.companyx_bpn
}

output "companyy_bpn" {
  description = "Company Y Business Partner Number"
  value       = var.companyy_bpn
}

########################################
# Kubernetes Namespaces
########################################

output "authority_namespace" {
  description = "Kubernetes namespace for authority components"
  value       = var.authority_namespace
}

output "companyx_namespace" {
  description = "Kubernetes namespace for Company X components"
  value       = var.companyx_namespace
}

output "companyy_namespace" {
  description = "Kubernetes namespace for Company Y components"
  value       = var.companyy_namespace
}

########################################
# API Endpoints Summary
########################################

output "all_endpoints" {
  description = "Summary of all data space endpoints"
  value = {
    issuer    = "https://issuer.${local.domain_name}"
    bdrs      = "https://bdrs.${local.domain_name}"
    companyx  = "https://companyx.${local.domain_name}"
    companyy  = "https://companyy.${local.domain_name}"
  }
}

########################################
# Postman Collection Information
########################################

output "postman_collections" {
  description = "Postman collections available for testing"
  value = {
    companyx_collection = "../data-sharing/api-collections/companyx.postman_collection.json"
    companyy_collection = "../data-sharing/api-collections/companyy.postman_collection.json"
    setup_instructions = [
      "1. Import both collections into Postman",
      "2. Set COMPANY_X_CONNECTOR_URL = https://companyx.${local.domain_name}",
      "3. Set COMPANY_Y_CONNECTOR_URL = https://companyy.${local.domain_name}",
      "4. Update other collection variables as needed"
    ]
  }
}

########################################
# Verification Commands
########################################

output "verification_commands" {
  description = "Commands to verify the data space deployment"
  value = [
    "# Check all pods are running:",
    "kubectl get pods --all-namespaces | grep -E '(authority|companyx|companyy)'",
    "",
    "# Verify endpoints are accessible:",
    "curl -k https://issuer.${local.domain_name}/.well-known/did.json",
    "curl -k https://bdrs.${local.domain_name}/health",
    "curl -k https://companyx.${local.domain_name}/api/v1/management/health",
    "curl -k https://companyy.${local.domain_name}/api/v1/management/health",
    "",
    "# Check DNS resolution:",
    "nslookup issuer.${local.domain_name}",
    "nslookup bdrs.${local.domain_name}",
    "nslookup companyx.${local.domain_name}",
    "nslookup companyy.${local.domain_name}"
  ]
}

########################################
# Next Steps Guide
########################################

output "next_steps" {
  description = "Next steps after data space deployment"
  value = [
    "1. Import Postman collections from ../data-sharing/api-collections/",
    "2. Update collection variables with the connector URLs above",
    "3. Create S3 buckets for data sharing (see README.md)",
    "4. Set up IAM users and policies for S3 access",
    "5. Register data assets using the Company X Postman collection",
    "6. Test data sharing between Company X and Company Y"
  ]
}

########################################
# Quick Access Information
########################################

output "quick_access" {
  description = "Quick access information for common tasks"
  value = {
    kubectl_context = data.terraform_remote_state.eks.outputs.kubectl_config_command
    aws_console_url = "https://${data.terraform_remote_state.eks.outputs.aws_region}.console.aws.amazon.com/eks/home?region=${data.terraform_remote_state.eks.outputs.aws_region}#/clusters/${data.terraform_remote_state.eks.outputs.cluster_name}"
    postman_setup = "Import collections from ../data-sharing/api-collections/ and set connector URLs from the endpoints above"
  }
}
