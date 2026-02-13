locals {
  istio_repo = "https://istio-release.storage.googleapis.com/charts"
  istio_ns   = "istio-system"
  version    = "1.21.6" # 원하면 나중에 올려도 됨
}

resource "helm_release" "istio_base" {
  name             = "istio-base"
  repository       = local.istio_repo
  chart            = "base"
  version          = local.version
  namespace        = local.istio_ns
  create_namespace = true
}

resource "helm_release" "istiod" {
  name       = "istiod"
  repository = local.istio_repo
  chart      = "istiod"
  version    = local.version
  namespace  = local.istio_ns

  depends_on = [helm_release.istio_base]
}

resource "helm_release" "ingressgateway" {
  name       = "istio-ingressgateway"
  repository = local.istio_repo
  chart      = "gateway"
  version    = local.version
  namespace  = local.istio_ns

  wait    = false          # ⭐ 핵심
  timeout = 600

  atomic  = false          # ⭐ 중요
  replace = true

  values = [
    yamlencode({
      service = {
        type = "LoadBalancer"
        loadBalancerClass = null
        annotations = {
          "service.beta.kubernetes.io/aws-load-balancer-scheme" = "internet-facing"
          "service.beta.kubernetes.io/aws-load-balancer-type" = "nlb"
        #   "service.beta.kubernetes.io/aws-load-balancer-type" = "nlb-ip"
        #   "service.beta.kubernetes.io/aws-load-balancer-scheme" = "internet-facing"
        #   "service.beta.kubernetes.io/aws-load-balancer-nlb-target-type" = "ip"
        }

        ports = [
          { name = "http2", port = 80,  targetPort = 8080 },
          { name = "https", port = 443, targetPort = 8443 },
        ]
      }
    })
  ]

  depends_on = [helm_release.istiod]
}
