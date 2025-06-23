variable "humanReadableName" {
  type        = string
  description = "Human readable name of the connector, NOT the BPN!!. Required."
}

variable "namespace" {
  description = "Kubernetes namespace for the ingress"
  type        = string
}

variable "additional_annotations" {
  description = "Additional annotations to add to the ingress"
  type        = map(string)
  default     = {}
}

variable "albc_ingress_class_name" {
  description = "AWS Load Balancer Controller ingress class name"
  type        = string
  default     = "alb"
}

variable "domain_name" {
  description = "Base domain name for the ingress"
  type        = string
}

variable "connector_services" {
  description = "Configuration for the connector services"
  type = object({
    controlplane = object({
      ports = object({
        api        = number
        management = number
        protocol   = number
      })
    })
    dataplane = object({
      ports = object({
        public = number
      })
    })
    identity_hub = object({
      ports = object({
        did         = number
        identity    = number
        credentials = number
        sts         = number
      })
    })
  })
  default = {
    controlplane = {
      ports = {
        api        = 8080
        management = 8081
        protocol   = 8084
      }
    }
    dataplane = {
      ports = {
        public = 8081
      }
    }
    identity_hub = {
      ports = {
        did         = 7083
        identity    = 7081
        credentials = 7082
        sts         = 7084
      }
    }
  }
}
