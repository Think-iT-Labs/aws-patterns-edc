resource "helm_release" "issuer" {
  name = "issuer"

  repository        = "oci://registry-1.docker.io/bitnamicharts"
  chart             = "nginx"
  version           = "20.1.2"
  namespace         = var.namespace
  force_update      = true
  dependency_update = true
  reuse_values      = true
  cleanup_on_fail   = true
  replace           = true

  values = [
    templatefile("${path.module}/values.yaml", {
      issuer_did_document    = kubernetes_config_map.issuer_did_document.metadata[0].name
      alb_ingress_class_name = var.albc_ingress_class_name
      issuer_host            = var.issuer_hostname
    })
  ]
}

resource "kubernetes_config_map" "issuer_did_document" {
  metadata {
    name      = "did-document"
    namespace = var.namespace
  }

  data = {
    "did.json" = file("${path.cwd}/${var.did_json_path}")
  }
}
