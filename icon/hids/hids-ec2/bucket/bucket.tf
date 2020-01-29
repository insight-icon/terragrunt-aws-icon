resource "random_pet" "bucket" {}

variable "bucket_name" {}

resource "aws_s3_bucket" "this" {
  bucket = var.bucket_name
  acl    = "private"
}

output "bucket" {
  value = aws_s3_bucket.this.bucket
}