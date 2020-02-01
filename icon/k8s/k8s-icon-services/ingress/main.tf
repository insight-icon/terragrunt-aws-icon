resource "kubernetes_config_map" "ingress_nginx_ingress_controller" {
  metadata {
    name = "ingress-nginx-ingress-controller"
  }

  data = {
    force-ssl-redirect = false

    ssl-redirect = false

    use-proxy-protocol = false
  }
}

data "helm_repository" "stable" {
  name = "stable"
  url  = "https://kubernetes-charts.storage.googleapis.com"
}

resource "helm_release" "ingress" {
  name  = "nginx-ingress"
  chart = "nginx-ingress"
  repository = data.helm_repository.stable.metadata[0].name
  namespace = "kube-system"

  set {
    name  = "controller.metrics.enabled"
    value = true
  }

  set {
    name  = "controller.stats.enabled"
    value = true
  }

  set {
    name  = "controller.metrics.serviceMonitor.enabled"
    value = true
  }

  set {
    name  = "rbac.create"
    value = true
  }

  set {
    name  = "controller.publishService.enabled"
    value = true
  }
}