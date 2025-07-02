# Kubernetes Job to seed the BDRS Server with BPNs and DIDs via the Management API
resource "kubernetes_job" "companyx_seed_bpn_via_mgmt_api" {
  depends_on = [module.bdrs-server]

  metadata {
    name      = "seed-bpns"
    namespace = kubernetes_namespace.authority_namespace.metadata[0].name
  }
  spec {
    // run only once
    completions     = 1
    completion_mode = "NonIndexed"
    // clean up any job pods after 90 seconds, failed or succeeded
    ttl_seconds_after_finished = "90"
    template {
      metadata {
        name = "seed-connectors"
      }
      spec {
        // seed the BDRS Server
        container {
          name  = "seed-bdrs"
          image = "postman/newman:ubuntu"
          command = [
            "newman", "run",
            "--folder", "SeedBDRS",
            "--env-var", "BDRS_MGMT_URL=${local.bdrs_internal_mgmt_url}",
            "--env-var", "COMPANYX_DID=${local.companies.companyx.participant_did}",
            "--env-var", "COMPANYY_DID=${local.companies.companyy.participant_did}",
            "--env-var", "COMPANYX_BPN=${var.companyx_bpn}",
            "--env-var", "COMPANYY_BPN=${var.companyy_bpn}",
            "--env-var", "BDRS_API_AUTH_KEY=${var.bdrs_api_auth_key}",
            "--reporters", "cli",
            "--reporter-cli-no-summary", "false",
            "--reporter-cli-no-assertions", "false",
            "--reporter-cli-no-failures", "false",
            "--reporter-cli-no-console", "false",
            "--verbose",
            "/opt/collection/${local.newman_collection_name}"
          ]
          volume_mount {
            mount_path = "/opt/collection"
            name       = "seed-collection"
          }
        }

        volume {
          name = "seed-collection"
          config_map {
            name = kubernetes_config_map.seed_collection["bdrs"].metadata.0.name
          }
        }
        // only restart when failed
        restart_policy = "OnFailure"
      }
    }
  }
}

# Kubernetes Job to seed IdentityHubs with participant and verifiable credentials via the Identity API
resource "kubernetes_job" "seed_connectors_via_mgmt_api" {
  for_each = local.companies

  depends_on = [
    module.companyx_tx-identity-hub,
    module.companyy_tx-identity-hub,
    module.companyx_connector_ingress,
    module.companyy_connector_ingress
  ]

  metadata {
    name      = "seed-connectors-${each.key}"
    namespace = each.value.namespace
  }

  spec {
    # run only once
    completions     = 1
    completion_mode = "NonIndexed"
    # clean up any job pods after 90 seconds, failed or succeeded
    ttl_seconds_after_finished = "90"

    template {
      metadata {
        name = "seed-connectors-${each.key}"
      }

      spec {
        # this container seeds the company's IdentityHub
        container {
          name  = "membership-cred-${each.key}"
          image = "postman/newman:ubuntu"
          command = [
            "newman", "run",
            "--folder", "SeedIH",
            "--env-var", "IH_URL=${each.value.ih_internal_url}",
            "--env-var", "PARTICIPANT_DID=${each.value.participant_did}",
            "--env-var", "PARTICIPANT_DID_BASE64=${each.value.participant_did_base64}",
            "--env-var", "ISSUER_DID=${local.issuer_did}",
            "--env-var", "IH_SUPERUSER_API_KEY=${each.value.ih_superuser_apikey}",
            "--env-var",
            "CONNECTOR_URL=https://${each.key}.${local.domain_name}",
            "--env-var", "MEMBERSHIP_CREDENTIAL=${file("${path.module}/${each.value.vc_membership_path}")}",
            "--env-var", "BPN=${each.value.bpn}",
            "--reporters", "cli",
            "--reporter-cli-no-summary", "false",
            "--reporter-cli-no-assertions", "false",
            "--reporter-cli-no-failures", "false",
            "--reporter-cli-no-console", "false",
            "--verbose",
            "/opt/collection/${local.newman_collection_name}"
          ]

          volume_mount {
            mount_path = "/opt/collection"
            name       = "seed-collection"
          }
        }

        volume {
          name = "seed-collection"
          config_map {
            name = kubernetes_config_map.seed_collection[each.key].metadata.0.name
          }
        }

        # only restart when failed
        restart_policy = "OnFailure"
      }
    }
  }
}

# Kubernetes ConfigMap to store seed collection data for each entity
resource "kubernetes_config_map" "seed_collection" {
  for_each = local.seed_collections

  metadata {
    name      = "mvds-seed-collection"
    namespace = each.value
  }

  data = {
    (local.newman_collection_name) = file("./assets/seed/mvds-seed.json")
  }
}

locals {
  newman_collection_name = "mvds-seed.json"

  bdrs_internal_service   = "bdrs-server"
  bdrs_internal_mgmt_port = 8081
  bdrs_internal_mgmt_url  = "http://${local.bdrs_internal_service}:${local.bdrs_internal_mgmt_port}/api/management"

  companyx_ih_internal_service       = "${lower(var.companyx_humanReadableName)}-tractusx-identityhub"
  companyx_ih_internal_identity_port = 7081

  companyy_ih_internal_service       = "${lower(var.companyy_humanReadableName)}-tractusx-identityhub"
  companyy_ih_internal_identity_port = 7081

  seed_collections = {
    bdrs     = kubernetes_namespace.authority_namespace.metadata[0].name
    companyx = kubernetes_namespace.companyx_namespace.metadata[0].name
    companyy = kubernetes_namespace.companyy_namespace.metadata[0].name
  }

  companyx_participant_did = "did:web:companyx.${local.domain_name}"
  companyy_participant_did = "did:web:companyy.${local.domain_name}"
  issuer_did               = "did:web:issuer.${local.domain_name}"

  companies = {
    companyx = {
      namespace              = var.companyx_namespace
      participant_did        = "did:web:companyx.${local.domain_name}"
      participant_did_base64 = base64encode(local.companyx_participant_did)
      vc_membership_path     = "assets/did/companyx.membership.jwt"
      bpn                    = var.companyx_bpn
      ih_superuser_apikey    = var.companyx_ih_superuser_apikey
      module_dependency      = module.companyx_tx-identity-hub
      ih_internal_url        = "http://${local.companyx_ih_internal_service}:${local.companyx_ih_internal_identity_port}"
    }
    companyy = {
      namespace              = var.companyy_namespace
      participant_did        = "did:web:companyy.${local.domain_name}"
      participant_did_base64 = base64encode(local.companyy_participant_did)
      vc_membership_path     = "assets/did/companyy.membership.jwt"
      bpn                    = var.companyy_bpn
      ih_superuser_apikey    = var.companyy_ih_superuser_apikey
      module_dependency      = module.companyy_tx-identity-hub
      ih_internal_url        = "http://${local.companyy_ih_internal_service}:${local.companyy_ih_internal_identity_port}"
    }
  }
}
