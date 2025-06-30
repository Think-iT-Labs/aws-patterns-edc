##############################################
# Global configuration
##############################################

variable "project_name" {
  type        = string
  description = "Name of the project"
}

# Local value to get domain_name from EKS remote state
locals {
  domain_name = data.terraform_remote_state.eks.outputs.domain_name
}

variable "tx-identity-hub_image" {
  type    = string
  default = "tx-identityhub:latest"
}

variable "albc_ingress_class_name" {
  type        = string
  description = "Ingress class name for the ALB controller"
  default     = "alb"
}

##############################################
# Authority configuration
##############################################

variable "issuer_did_json_path" {
  type        = string
  default     = "assets/did/issuer.did.json"
  description = "Path to the Issuer DID JSON file"
}

variable "authority_namespace" {
  default = "authority"
}

variable "bdrs_api_auth_key" {
  description = "API authentication key for the BDRS server"
  default     = "password"
}

##############################################
# CompanyX configuration
##############################################

variable "companyx_namespace" {
  type    = string
  default = "companyx"
}

variable "companyx_bpn" {
  default = "BPNL000000000001"
}

variable "companyx_humanReadableName" {
  default = "companyx"
}

variable "companyx_datasource" {
  default = {
    database_port  = 5432
    admin_password = "postgres"
    database_name  = "edc"
    username       = "edc"
    password       = "password"
  }
}

variable "companyx_ih_superuser_apikey" {
  default     = "c3VwZXItdXNlcg==.c3VwZXItc2VjcmV0LWtleQo="
  description = "Management API Key for the Super-User. Defaults to 'base64(super-user).base64(super-secret-key)"
  type        = string
}

##############################################
# CompanyY configuration
##############################################

variable "companyy_namespace" {
  default = "companyy"
}

variable "companyy_bpn" {
  default = "BPNL000000000002"
}

variable "companyy_humanReadableName" {
  default = "companyy"
}

variable "companyy_datasource" {
  default = {
    database_port  = 5432
    admin_password = "postgres"
    database_name  = "edc"
    username       = "edc"
    password       = "password"
  }
}

variable "companyy_ih_superuser_apikey" {
  default     = "c3VwZXItdXNlcg==.c3VwZXItc2VjcmV0LWtleQo="
  description = "Management API Key for the Super-User. Defaults to 'base64(super-user).base64(super-secret-key)"
  type        = string
}
