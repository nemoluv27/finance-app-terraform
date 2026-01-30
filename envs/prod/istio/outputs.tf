output "istio_namespace" {
  value = local.istio_ns
}

output "ingress_release" {
  value = helm_release.ingressgateway.name
}
