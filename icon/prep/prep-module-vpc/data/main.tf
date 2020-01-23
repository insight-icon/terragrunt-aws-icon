
module "label" {
  source = "git::https://github.com/cloudposse/terraform-null-label.git?ref=master"
  context = var.context
  name = "prep-module-vpc"
}

data "aws_eip" "this" {
  filter {
    name = "tag:Name"
    values = ["${var.network_name}-ip"]
  }

//  dynamic "filter" {
//    for_each = var.context.tags
//    content {
//      name = "tag:${filter.key}"
//      values = [filter.value]
//    }
//  }
}

data "aws_vpc" "this" {
  dynamic "filter" {
    for_each = var.context.tags
    content {
      name = "tag:${filter.key}"
      values = [filter.value]
    }
  }
}

data "aws_subnet_ids" "public" {
  vpc_id = data.aws_vpc.this.id

  filter {
    name = "tag:Name"
    values = [
      "*public*"]
  }
}

data "aws_subnet_ids" "private" {
  vpc_id = data.aws_vpc.this.id

  filter {
    name = "tag:Name"
    values = [
      "*private*"]
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

data "aws_security_group" "this" {
  dynamic "filter" {
    for_each = merge(module.label.tags, {Name: "prep-t1"})
    content {
      name = "tag:${filter.key}"
      values = [filter.value]
    }
  }
}

//data "aws_vpc" "this" {
//    filter {
//    name = "tag:Namespace"
//    values = [var.namespace]
//  }
//
//  filter {
//    name = "tag:Environment"
//    values = [var.environment]
//  }
//
//  filter {
//    name = "tag:NetworkName"
//    values = [var.network_name]
//  }
////  TODO: Consider variable here
//  filter {
//    name = "tag:VpcType"
//    values = ["main"]
//  }
//}