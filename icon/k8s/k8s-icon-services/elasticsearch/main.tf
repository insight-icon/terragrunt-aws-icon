
data "helm_repository" "stable" {
  name = "stable"
  url  = "https://kubernetes-charts.storage.googleapis.com"
}

data "template_file" "consul" {
// Hack to remove comments in yaml that jam up parser
  template = yamlencode(yamldecode(file("${path.module}/elasticsearch-config.yaml")))
}

resource "helm_release" "consul" {
  name  = "elasticsearch"
  chart = "elasticsearch"
  repository = data.helm_repository.stable.metadata[0].name
  namespace = "kube-system"

  values = [data.template_file.consul.rendered]
}