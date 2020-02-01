data "aws_region" "current" {}

variable "name" {}

//resource "aws_eip" "this" {
//
//  vpc = true
//
//  tags = {
//    Name = var.name
//    Region = data.aws_region.current.name
//  }
//
//  lifecycle {
//    prevent_destroy = false
//  }
//}

//output "eip_id" {
//  value = aws_eip.this.id
//}
//
//output "public_ip" {
//  value = aws_eip.this.public_ip
//}

data "aws_eip" "this" {
  filter {
    name = "tag:Name"
    values = ["icon"]
  }
}

output "eip_id" {
  value = data.aws_eip.this.id
}

output "public_ip" {
  value = data.aws_eip.this.public_ip
}