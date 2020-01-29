data "aws_caller_identity" "this" {}
data "aws_region" "current" {}

terraform {
  required_version = ">= 0.12"
}

variable "private_tld" {
  type = string
}

data aws_route53_zone "private" {
  name = "${var.private_tld}."
  private_zone = true
}


variable "region" {
  default = "us-east-1"
}

data "aws_instances" "consul_ec2_instances" {
  instance_tags = {
    Name = "vault-servers"
  }
  instance_state_names = ["running"]
}

data "aws_instance" "consul_ec2_indiv_instance" {
  count = 3

  instance_id = data.aws_instances.consul_ec2_instances.ids[count.index]
}

## Create A records for servers
resource "aws_route53_record" "consul_servers" {
  allow_overwrite = true
  name            = join(".", ["vault-srv", var.region])
  ttl             = 30
  type            = "A"
  zone_id         = data.aws_route53_zone.private.zone_id

  records = data.aws_instance.consul_ec2_indiv_instance[*].private_ip
}