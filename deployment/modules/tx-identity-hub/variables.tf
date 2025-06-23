variable "humanReadableName" {
  type        = string
  description = "Human readable name of the connector, NOT the ID!!. Required."
}

variable "participantId" {
  type        = string
  description = "Participant ID of the connector. Usually a DID"
}

variable "namespace" {
  type        = string
  description = "Kubernetes namespace to use"
}

variable "ports" {
  type = object({
    web             = number
    ih-identity-api = number
    credentials-api = number
    ih-did          = number
    sts-api         = number
    debug           = number
  })
  default = {
    web             = 7080
    ih-identity-api = 7081
    credentials-api = 7082
    ih-did          = 7083
    sts-api         = 7084
    debug           = 1044
  }
}

variable "ih_superuser_apikey" {
  default     = "c3VwZXItdXNlcg==.c3VwZXItc2VjcmV0LWtleQo="
  description = "Management API Key for the Super-User. Defaults to 'base64(super-user).base64(super-secret-key)"
  type        = string
}

variable "vault-url" {
  description = "URL of the Hashicorp Vault"
  type        = string
}

variable "vault-token" {
  default     = "root"
  description = "This is the authentication token for the vault. DO NOT USE THIS IN PRODUCTION!"
  type        = string
}

variable "aliases" {
  type = object({
    sts-private-key   = string
    sts-public-key-id = string
  })
  default = {
    sts-private-key   = "key-1"
    sts-public-key-id = "key-1"
  }
}

variable "datasource" {
  type = object({
    url      = string
    username = string
    password = string
  })
}

variable "image" {
  type    = string
  default = "tx-identityhub:latest"
}

variable "useSVE" {
  type        = bool
  description = "If true, the -XX:UseSVE=0 switch (Scalable Vector Extensions) will be appended to the JAVA_TOOL_OPTIONS. Can help on macOs on Apple Silicon processors"
  default     = false
}

variable "sts-token-path" {
  description = "path suffix of the STS token API"
  type        = string
  default     = "/api/sts"
}
