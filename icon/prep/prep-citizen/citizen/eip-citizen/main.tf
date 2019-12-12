data "aws_region" "current" {}
variable "instance_id" {}

variable "create_eip" {
  type = bool
  default = true
}

variable "public_ip" {
  type = string
  default = ""
}

// If you supply a public IP then you retrieve the resource, otherwise you create a new one.
data "aws_eip" "this"  {
  count = var.public_ip == "" ? 1 : 0

  public_ip = var.public_ip
}

resource "aws_eip" "this" {
  count = var.public_ip == "" ? 0 : 1

  tags = {
    Name = "main-ip"
    Region = data.aws_region.current.name
  }

  lifecycle {
    prevent_destroy = false
  }
}

resource "aws_eip_association" "main" {
  count = var.instance_id == "" ? 0 : 1

  instance_id = var.instance_id
  allocation_id = var.public_ip == "" ? aws_eip.this.id : data.aws_eip.this.*.id[0]
}

output "eip_id" {
  value = var.public_ip == "" ? aws_eip.this.*.id[0] : data.aws_eip.this.*.id[0]
}

output "public_ip" {
  value = var.public_ip == "" ? aws_eip.this.*.public_ip[0] : var.public_ip
}