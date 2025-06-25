variable "namespace" {
  type        = string
  description = "Kubernetes namespace to use"
}

variable "humanReadableName" {
  type        = string
  description = "Human readable name of the connector, NOT the BPN!!. Required."
}

variable "participantId" {
  type        = string
  description = "Participant ID of the connector. MUST be the BPN"
}

variable "datasource" {
  default = {
    database_port  = 5432
    admin_password = "postgres"
    database_name  = "edc"
    username       = "edc"
    password       = "password"
  }
}

variable "dcp_config" {
  type = object({
    id                     = string
    sts_token_url          = string
    sts_client_id          = string
    sts_clientsecret_alias = string
    issuer                 = string
  })
  default = {
    id                     = ""
    sts_token_url          = ""
    sts_client_id          = ""
    sts_clientsecret_alias = ""
    issuer                 = ""
  }
}

variable "dataplane" {
  type = object({
    privatekey_alias = string
    publickey_alias  = string
  })
}

variable "connector_hostname" {
  description = "Connector Host"
  default     = "localhost"
}

variable "bdrs_hostname" {
  type        = string
  description = "Host of the BDRS server"
}
