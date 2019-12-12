variable "aws_region" {
  description = "AWS region to use for all resources"
}

variable "aws_allowed_account_ids" {
  description = "List of allowed AWS accounts where this configuration can be applied"
  type        = list(string)
}

variable "cluster_id" {
  description = "The cluster id or cluster name for the EKS cluster"
  type = string
}

provider "aws" {
  version = "~> 2.2"

  region              = var.aws_region
  allowed_account_ids = var.aws_allowed_account_ids

  # Make it faster by skipping some things
  skip_get_ec2_platforms     = true
  skip_metadata_api_check    = true
  skip_region_validation     = true
  skip_requesting_account_id = true
}

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

provider "helm" {
  service_account = "tiller"
  namespace       = "kube-system"
  install_tiller = true

  kubernetes {
    load_config_file       = false

    host                   = data.aws_eks_cluster.this.endpoint
    token                  = data.aws_eks_cluster_auth.this.token
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.this.certificate_authority.0.data)
  }
}

terraform {
  backend "s3" {}
}
