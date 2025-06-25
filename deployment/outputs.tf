output "bdrs_url" {
  value = "https://bdrs.${var.domain_name}"
}

output "issuer_url" {
  value = "https://issuer.${var.domain_name}"
}

output "companyx_connector_url" {
  value = "https://companyx.${var.domain_name}"
}

output "companyx_ih_superuser_apikey" {
  value = module.companyx_tx-identity-hub.ih_superuser_apikey
  # sensitive = true
}

output "companyy_connector_url" {
  value = "https://companyy.${var.domain_name}"
}

output "companyy_ih_superuser_apikey" {
  value = module.companyy_tx-identity-hub.ih_superuser_apikey
  # sensitive = true
}
