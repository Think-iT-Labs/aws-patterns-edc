# CompanyX namespace
resource "kubernetes_namespace" "companyx_namespace" {
  metadata {
    name = var.companyx_namespace
  }
}

# CompanyX tx-connector
module "companyx_tx-connector" {
  source = "./modules/tx-connector"

  humanReadableName = var.companyx_humanReadableName
  namespace         = kubernetes_namespace.companyx_namespace.metadata[0].name
  participantId     = var.companyx_bpn

  dcp_config = {
    id                     = "did:web:companyx.${var.domain_name}"
    sts_token_url          = "https://companyx.${var.domain_name}/api/sts/token"
    sts_client_id          = "did:web:companyx.${var.domain_name}"
    sts_clientsecret_alias = "did:web:companyx.${var.domain_name}-sts-client-secret"
    issuer                 = "did:web:issuer.${var.domain_name}"
  }

  dataplane = {
    privatekey_alias = "did:web:companyx.${var.domain_name}#signing-key-1"
    publickey_alias  = "did:web:companyx.${var.domain_name}#signing-key-1"
  }

  connector_hostname = "companyx.${var.domain_name}"
  bdrs_hostname      = "bdrs.${var.domain_name}"
}

# CompanyX tx-identity-hub
module "companyx_tx-identity-hub" {
  depends_on = [module.companyx_tx-connector]

  source = "./modules/tx-identity-hub"

  humanReadableName   = var.companyx_humanReadableName
  namespace           = kubernetes_namespace.companyx_namespace.metadata[0].name
  participantId       = var.companyx_bpn
  vault-url           = local.companyx_vault-url
  ih_superuser_apikey = var.companyx_ih_superuser_apikey

  aliases = {
    sts-private-key   = "did:web:issuer.${var.domain_name}#signing-key-1"
    sts-public-key-id = "did:web:issuer.${var.domain_name}#signing-key-1"
  }

  datasource = {
    username = var.companyx_datasource.username
    password = var.companyx_datasource.password
    url      = local.companyx_jdbcUrl
  }

  image = var.tx-identity-hub_image
}

# CompanyX ingress for tx-connector and tx-identity-hub
module "companyx_connector_ingress" {
  depends_on = [module.companyx_tx-identity-hub]

  source = "./modules/tx-connector-ingress"

  humanReadableName = var.companyx_humanReadableName
  namespace         = kubernetes_namespace.companyx_namespace.metadata[0].name
  domain_name       = var.domain_name

}

locals {
  companyx_vault-url = "http://${lower(var.companyx_humanReadableName)}-vault:8200"
  companyx_jdbcUrl   = "jdbc:postgresql://${lower(var.companyx_humanReadableName)}-postgresql:${var.companyx_datasource.database_port}/${var.companyx_datasource.database_name}"
}
