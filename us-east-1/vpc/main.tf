
#############
# default vpc
#############

data "aws_vpc" "default" {
  default = true
}

data "aws_subnet_ids" "default_subnets" {
  vpc_id = data.aws_vpc.default.id
}

output "vpc_id" {
  value = data.aws_vpc.default.id
}

output "public_subnets" {
  value = tolist(data.aws_subnet_ids.default_subnets.ids)
}