variable "instance_id" {}
variable "eip_id" {}

resource "aws_eip_association" "main" {
  instance_id = var.instance_id
  allocation_id = var.eip_id
}

output "public_ip" {
  value = aws_eip_association.main.public_ip
}
