variable "tags" {
  type = map(string)
}

data "aws_eip" "this" {
  tags = var.tags
}

output "eip_id" {
  value = data.aws_eip.this.id
}

output "public_ip" {
  value = data.aws_eip.this.public_ip
}