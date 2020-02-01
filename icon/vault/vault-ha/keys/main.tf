variable "name" {
  type = string
}

variable "local_public_key" {
  type = string
}

data "local_file" "key_local" {
  filename = var.local_public_key
}

resource "aws_key_pair" "key" {
  key_name = var.name
  public_key = data.local_file.key_local.content
}

output "key_name" {
  value = aws_key_pair.key.key_name
}

output "public_key" {
  value = aws_key_pair.key.public_key
}