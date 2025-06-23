resource "helm_release" "tx_connector" {
  name = lower(var.humanReadableName)

  repository        = "https://eclipse-tractusx.github.io/charts/dev"
  chart             = "tractusx-connector"
  version           = "0.9.0"
  namespace         = var.namespace
  force_update      = true
  dependency_update = true
  reuse_values      = true
  cleanup_on_fail   = true
  replace           = true

  values = [
    templatefile("${path.module}/values.yaml", {
      participant_id                     = var.participantId
      participant_did                    = var.dcp_config.id
      issuer_did                         = var.dcp_config.issuer
      sts_token_url                      = var.dcp_config.sts_token_url
      sts_client_id                      = var.dcp_config.sts_client_id
      sts_secret_alias                   = var.dcp_config.sts_clientsecret_alias
      edc_hostname                       = "${var.humanReadableName}-tractusx-connector-controlplane"
      edc_dsp_callback_address           = "https://${var.connector_hostname}/api/v1/dsp"
      bdrs_server_url                    = "https://${var.bdrs_hostname}/api/directory"
      dataplane_signer_privatekey_alias  = var.dataplane.privatekey_alias
      dataplane_verifier_publickey_alias = var.dataplane.publickey_alias
      postgresql_jdbc_url                = local.jdbcUrl
      postgresql_auth_postgres_password  = var.datasource.admin_password
      postgresql_auth_username           = var.datasource.username
      postgresql_auth_password           = var.datasource.password
      postgresql_auth_database           = var.datasource.database_name
    })
  ]
}

locals {
  jdbcUrl = "jdbc:postgresql://{{ .Release.Name }}-postgresql:${var.datasource.database_port}/${var.datasource.database_name}"
}
