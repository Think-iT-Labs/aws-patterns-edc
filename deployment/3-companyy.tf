# CompanyY namespace
resource "kubernetes_namespace" "companyy_namespace" {
  metadata {
    name = var.companyy_namespace
  }
}

# CompanyY tx-connector
module "companyy_tx-connector" {
  source = "./modules/tx-connector"

  humanReadableName = var.companyy_humanReadableName
  namespace         = kubernetes_namespace.companyy_namespace.metadata.0.name
  participantId     = var.companyy_bpn

  dcp_config = {
    id                     = "did:web:companyy.${var.domain_name}"
    sts_token_url          = "https://companyy.${var.domain_name}/api/sts/token"
    sts_client_id          = "did:web:companyy.${var.domain_name}"
    sts_clientsecret_alias = "did:web:companyy.${var.domain_name}-sts-client-secret"
    issuer                 = "did:web:issuer.${var.domain_name}"
  }

  dataplane = {
    privatekey_alias = "did:web:companyy.${var.domain_name}#signing-key-1"
    publickey_alias  = "did:web:companyy.${var.domain_name}#signing-key-1"
  }

  connector_hostname = "companyy.${var.domain_name}"
  bdrs_hostname      = "bdrs.${var.domain_name}"
}

# CompanyY tx-identity-hub
module "companyy_tx-identity-hub" {
  depends_on = [module.companyy_tx-connector]

  source = "./modules/tx-identity-hub"

  humanReadableName   = var.companyy_humanReadableName
  namespace           = kubernetes_namespace.companyy_namespace.metadata.0.name
  participantId       = var.companyy_bpn
  vault-url           = local.companyy_vault-url
  ih_superuser_apikey = var.companyy_ih_superuser_apikey

  aliases = {
    sts-private-key   = "did:web:issuer.${var.domain_name}#signing-key-1"
    sts-public-key-id = "did:web:issuer.${var.domain_name}#signing-key-1"
  }

  datasource = {
    username = var.companyy_datasource.username
    password = var.companyy_datasource.password
    url      = local.companyy_jdbcUrl
  }

  image = var.tx-identity-hub_image
}

# CompanyY ingress for tx-connector and tx-identity-hub
module "companyy_connector_ingress" {
  depends_on = [module.companyy_tx-identity-hub]

  source = "./modules/tx-connector-ingress"

  humanReadableName = var.companyy_humanReadableName
  namespace         = kubernetes_namespace.companyy_namespace.metadata[0].name
  domain_name       = var.domain_name

}

locals {
  companyy_vault-url = "http://${lower(var.companyy_humanReadableName)}-vault:8200"
  companyy_jdbcUrl   = "jdbc:postgresql://${lower(var.companyy_humanReadableName)}-postgresql:${var.companyy_datasource.database_port}/${var.companyy_datasource.database_name}"
}
