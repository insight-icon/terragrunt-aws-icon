data "aws_region" "this" {}

variable "name" {
  description = "The name of the helm release"
  type = string
}

variable "namespace" {
  description = "The namespace to deploy the chart into"
  type = string
  default = "kube-system"
}

data "helm_repository" "stable" {
  name = "stable"
  url  = "https://kubernetes-charts.storage.googleapis.com"
}

data "template_file" "consul" {
// Hack to remove comments that jam up parser
  template = yamlencode(yamldecode(file("${path.module}/consul.yaml")))

  vars = {
    region = data.aws_region.this.name
  }
}

resource "helm_release" "consul" {
  name  = var.name
  chart = var.name
  repository = data.helm_repository.stable.metadata[0].name
  namespace = var.namespace

  values = [data.template_file.consul.rendered]
}