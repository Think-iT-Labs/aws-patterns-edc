resource "kubernetes_ingress_v1" "companyx_ingress" {
  metadata {
    name      = var.humanReadableName
    namespace = var.namespace
    annotations = merge(
      {
        "alb.ingress.kubernetes.io/listen-ports"     = "[{\"HTTP\": 80}, {\"HTTPS\":443}]"
        "alb.ingress.kubernetes.io/ssl-redirect"     = "443"
        "alb.ingress.kubernetes.io/scheme"           = "internet-facing"
        "alb.ingress.kubernetes.io/target-type"      = "ip"
        "alb.ingress.kubernetes.io/healthcheck-path" = "/api/check/liveness"
        "alb.ingress.kubernetes.io/healthcheck-port" = "8080"
        "alb.ingress.kubernetes.io/group.name"       = "aws-patterns-edc"
      },
      var.additional_annotations
    )
  }

  spec {
    ingress_class_name = var.albc_ingress_class_name

    rule {
      host = "${var.humanReadableName}.${local.domain_name}"

      http {
        path {
          path      = "/api/check/liveness"
          path_type = "Prefix"
          backend {
            service {
              name = "${var.humanReadableName}-tractusx-connector-controlplane"
              port {
                number = var.connector_services.controlplane.ports.api
              }
            }
          }
        }
        path {
          path      = "/management"
          path_type = "Prefix"
          backend {
            service {
              name = "${var.humanReadableName}-tractusx-connector-controlplane"
              port {
                number = var.connector_services.controlplane.ports.management
              }
            }
          }
        }
        path {
          path      = "/api/v1/dsp"
          path_type = "Prefix"
          backend {
            service {
              name = "${var.humanReadableName}-tractusx-connector-controlplane"
              port {
                number = var.connector_services.controlplane.ports.protocol
              }
            }
          }
        }
        path {
          path      = "/api/public"
          path_type = "Prefix"
          backend {
            service {
              name = "${var.humanReadableName}-tractusx-connector-dataplane"
              port {
                number = var.connector_services.dataplane.ports.public
              }
            }
          }
        }
        path {
          path      = "/api/identity"
          path_type = "Prefix"
          backend {
            service {
              name = "${var.humanReadableName}-tractusx-identityhub"
              port {
                number = var.connector_services.identity_hub.ports.identity
              }
            }
          }
        }
        path {
          path      = "/api/credentials"
          path_type = "Prefix"
          backend {
            service {
              name = "${var.humanReadableName}-tractusx-identityhub"
              port {
                number = var.connector_services.identity_hub.ports.credentials
              }
            }
          }
        }
        path {
          path      = "/api/sts"
          path_type = "Prefix"
          backend {
            service {
              name = "${var.humanReadableName}-tractusx-identityhub"
              port {
                number = var.connector_services.identity_hub.ports.sts
              }
            }
          }
        }
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = "${var.humanReadableName}-tractusx-identityhub"
              port {
                number = var.connector_services.identity_hub.ports.did
              }
            }
          }
        }
      }
    }
  }
}
