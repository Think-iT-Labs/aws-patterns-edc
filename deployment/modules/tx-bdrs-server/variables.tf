variable "namespace" {
  type        = string
  description = "Kubernetes namespace to use"
  default     = "authority"
}

variable "datasource" {
  default = {
    database_port  = 5432
    admin_password = "postgres"
    database_name  = "bdrs"
    username       = "bdrs"
    password       = "password"
  }
}

variable "issuer_did" {
  type        = string
  description = "Dataspace issuer DID"
}

variable "albc_ingress_class_name" {
  type        = string
  description = "Ingress class name for the ALB controller"
  default     = "alb"
}

variable "api_auth_key" {
  description = "API authentication key for the BDRS server"
  default = "password"
}

variable "bdrs_hostname" {
  default = ""
}
