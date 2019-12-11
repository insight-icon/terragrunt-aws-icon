resource "aws_s3_bucket_object" "logo_256" {
  count = var.logo_256 == "" ? 0 : 1
  bucket = aws_s3_bucket.bucket.bucket
  key = basename(var.logo_256)
  source = var.logo_256
}

resource "aws_s3_bucket_object" "logo_1024" {
  count = var.logo_1024 == "" ? 0 : 1
  bucket = aws_s3_bucket.bucket.bucket
  key = basename(var.logo_1024)
  source = var.logo_1024
}

resource "aws_s3_bucket_object" "logo_svg" {
  count = var.logo_svg == "" ? 0 : 1
  bucket = aws_s3_bucket.bucket.bucket
  key = basename(var.logo_svg)
  source = var.logo_svg
}
