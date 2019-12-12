variable "cluster_id" {}

data "aws_eks_cluster" "this" {
  name = var.cluster_id
}

data "aws_eks_cluster_auth" "this" {
  name = var.cluster_id
}

provider "kubernetes" {
  load_config_file       = false

  host                   = data.aws_eks_cluster.this.endpoint
  token                  = data.aws_eks_cluster_auth.this.token
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.this.certificate_authority.0.data)
}

