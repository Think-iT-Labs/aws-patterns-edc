resource "helm_release" "bdrs_server" {
  name = "bdrs-server"

  repository        = "https://eclipse-tractusx.github.io/charts/dev"
  chart             = "bdrs-server"
  version           = "0.5.2"
  namespace         = var.namespace
  force_update      = true
  dependency_update = true
  reuse_values      = true
  cleanup_on_fail   = true
  replace           = true

  values = [
    templatefile("${path.module}/values.yaml", {
      issuer_did                        = var.issuer_did
      alb_ingress_class_name            = var.albc_ingress_class_name
      bdrs-server_hostname              = var.bdrs_hostname
      api_auth_key                      = var.api_auth_key
      postgresql_jdbc_url               = local.jdbcUrl
      postgresql_auth_postgres_password = var.datasource.admin_password
      postgresql_auth_username          = var.datasource.username
      postgresql_auth_password          = var.datasource.password
      postgresql_auth_database          = var.datasource.database_name
    })
  ]
}

locals {
  jdbcUrl = "jdbc:postgresql://{{ .Release.Name }}-postgresql:${var.datasource.database_port}/${var.datasource.database_name}"
}
