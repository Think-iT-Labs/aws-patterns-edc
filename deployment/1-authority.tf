# Authority namespace
resource "kubernetes_namespace" "authority_namespace" {
  metadata {
    name = var.authority_namespace
  }
}

# Dataspace Issuer
module "dataspace_issuer" {
  source = "./modules/issuer"

  namespace       = kubernetes_namespace.authority_namespace.metadata[0].name
  issuer_hostname = "issuer.${local.domain_name}"
  did_json_path   = local.did_json_path
}

# Bdrs server
module "bdrs-server" {
  source = "./modules/tx-bdrs-server"

  namespace     = kubernetes_namespace.authority_namespace.metadata[0].name
  issuer_did    = "did:web:issuer.${local.domain_name}"
  api_auth_key  = var.bdrs_api_auth_key
  bdrs_hostname = "bdrs.${local.domain_name}"
}

locals {
  did_json_path = var.issuer_did_json_path
}
