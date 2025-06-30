output "ingress_name" {
  description = "Name of the created ingress"
  value       = kubernetes_ingress_v1.companyx_ingress.metadata[0].name
}

output "ingress_hostname" {
  description = "Hostname for the ingress"
  value       = "{var.humanReadableName}.${local.domain_name}"
}

output "ingress_annotations" {
  description = "Annotations applied to the ingress"
  value       = kubernetes_ingress_v1.companyx_ingress.metadata[0].annotations
}
