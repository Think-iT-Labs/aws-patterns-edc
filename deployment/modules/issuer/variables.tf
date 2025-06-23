variable "namespace" {
  type        = string
  description = "Kubernetes namespace to use"
  default     = "authority"
}

variable "issuer_hostname" {
  type        = string
  description = "Issuer hostname"
}

variable "albc_ingress_class_name" {
  type        = string
  description = "Ingress class name for the ALB controller"
  default     = "alb"
}

variable "did_json_path" {
  type        = string
  default     = "assets/did/documents/issuer/issuer.did.json"
  description = "Path to the DID JSON file"
}
