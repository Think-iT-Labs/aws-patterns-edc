resource "kubernetes_service" "ih-service" {
  metadata {
    name      = "${lower(var.humanReadableName)}-tractusx-identityhub"
    namespace = var.namespace
  }
  spec {
    type = "ClusterIP"
    selector = {
      App = kubernetes_deployment.identityhub.spec.0.template.0.metadata[0].labels.App
    }
    port {
      name = "credentials"
      port = var.ports.credentials-api
    }
    port {
      name = "debug"
      port = var.ports.debug
    }
    port {
      name = "identity"
      port = var.ports.ih-identity-api
    }
    port {
      name = "did"
      port = var.ports.ih-did
    }
    port {
      name = "sts"
      port = var.ports.sts-api
    }
  }
}
