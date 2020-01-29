variable "environment" {
  type = string
}

variable "namespace" {
  type = string
}

variable "network_name" {
  type = string
}

variable "vpc_type" {
  type = string
}

data "aws_vpc" "tags" {
  filter {
    name = "tag:Namespace"
    values = [var.namespace]
  }

  filter {
    name = "tag:Environment"
    values = [var.environment]
  }

  filter {
    name = "tag:NetworkName"
    values = [var.network_name]
  }

  filter {
    name = "tag:VpcType"
    values = [var.vpc_type]
  }
}

data "aws_subnet_ids" "public" {
  vpc_id = data.aws_vpc.tags.id

  filter {
    name = "tag:Name"
    values = ["*public*"]
  }
}

data "aws_subnet_ids" "private" {
  vpc_id = data.aws_vpc.tags.id

  filter {
    name = "tag:Name"
    values = ["*private*"]
  }
}

data "aws_subnet" "public" {
  count = length(data.aws_subnet_ids.public.ids)
  id = tolist(data.aws_subnet_ids.public.ids)[count.index]
}

data "aws_subnet" "private" {
  count = length(data.aws_subnet_ids.private.ids)
  id = tolist(data.aws_subnet_ids.private.ids)[count.index]
}

output "azs" {
  value = data.aws_subnet.public.*.availability_zone
}

output "vpc_id" {
  value = data.aws_vpc.tags.id
}

output "vpc_cidr_block" {
  value = data.aws_vpc.tags.cidr_block
}

output "public_subnets" {
  value = values(zipmap(data.aws_subnet.public.*.availability_zone, data.aws_subnet.public.*.id))
}

output "public_subnets_cidr_blocks" {
  value = values(zipmap(data.aws_subnet.public.*.availability_zone, data.aws_subnet.public.*.cidr_block))
}

output "private_subnets" {
  value = values(zipmap(data.aws_subnet.private.*.availability_zone, data.aws_subnet.private.*.id))
}

output "private_subnets_cidr_blocks" {
  value = values(zipmap(data.aws_subnet.private.*.availability_zone, data.aws_subnet.private.*.cidr_block))
}
