resource "kubernetes_deployment" "identityhub" {
  metadata {
    name = "${lower(var.humanReadableName)}-tractusx-identity-hub"
    namespace = var.namespace
    labels = {
      App = lower(var.humanReadableName)
    }
  }

  spec {
    replicas = 1
    selector {
      match_labels = {
        App = "${lower(var.humanReadableName)}-tractusx-identity-hub"
      }
    }

    template {
      metadata {
        labels = {
          App = "${lower(var.humanReadableName)}-tractusx-identity-hub"
        }
      }

      spec {
        container {
          image_pull_policy = "Always"
          image             = var.image
          name              = "tx-identityhub"

          env_from {
            config_map_ref {
              name = kubernetes_config_map.identityhub-config.metadata[0].name
            }
          }
          port {
            container_port = var.ports.credentials-api
            name           = "pres-port"
          }

          port {
            container_port = var.ports.debug
            name           = "debug"
          }
          port {
            container_port = var.ports.ih-identity-api
            name           = "identity"
          }
          port {
            container_port = var.ports.ih-did
            name           = "did"
          }
          port {
            container_port = var.ports.web
            name           = "default-port"
          }
          port {
            container_port = var.ports.sts-api
            name           = "sts-port"
          }

          liveness_probe {
            http_get {
              port = var.ports.web
              path = "/api/check/liveness"
            }
            failure_threshold = 10
            period_seconds    = 5
            timeout_seconds   = 30
          }

          readiness_probe {
            http_get {
              port = var.ports.web
              path = "/api/check/readiness"
            }
            failure_threshold = 10
            period_seconds    = 5
            timeout_seconds   = 30
          }

          startup_probe {
            http_get {
              port = var.ports.web
              path = "/api/check/startup"
            }
            failure_threshold = 10
            period_seconds    = 5
            timeout_seconds   = 30
          }
        }
      }
    }
  }
}

resource "kubernetes_config_map" "identityhub-config" {
  metadata {
    name      = "${lower(var.humanReadableName)}-config"
    namespace = var.namespace
  }

  data = {
    JAVA_TOOL_OPTIONS               = "${var.useSVE ? "-XX:UseSVE=0 " : ""}-agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=${var.ports.debug}"
    EDC_IH_IAM_ID                   = var.participantId
    EDC_IH_API_SUPERUSER_KEY        = var.ih_superuser_apikey
    EDC_IAM_STS_PRIVATEKEY_ALIAS    = var.aliases.sts-private-key
    EDC_IAM_STS_PUBLICKEY_ID        = var.aliases.sts-public-key-id
    EDC_SQL_SCHEMA_AUTOCREATE       = true
    EDC_DATASOURCE_DEFAULT_URL      = var.datasource.url
    EDC_DATASOURCE_DEFAULT_USER     = var.datasource.username
    EDC_DATASOURCE_DEFAULT_PASSWORD = var.datasource.password
    EDC_VAULT_HASHICORP_URL         = var.vault-url
    EDC_VAULT_HASHICORP_TOKEN       = var.vault-token
    WEB_HTTP_CREDENTIALS_PORT       = var.ports.credentials-api
    WEB_HTTP_CREDENTIALS_PATH       = "/api/credentials"
    WEB_HTTP_DID_PORT               = var.ports.ih-did
    WEB_HTTP_DID_PATH               = "/"
    WEB_HTTP_IDENTITY_PORT          = var.ports.ih-identity-api
    WEB_HTTP_IDENTITY_PATH          = "/api/identity"
    WEB_HTTP_IDENTITY_AUTH_KEY      = "password"
    WEB_HTTP_PORT                   = var.ports.web
    WEB_HTTP_PATH                   = "/api"
    WEB_HTTP_STS_PORT               = var.ports.sts-api
    WEB_HTTP_STS_PATH               = var.sts-token-path
  }
}
