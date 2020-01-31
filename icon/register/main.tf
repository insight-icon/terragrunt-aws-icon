data "aws_caller_identity" "this" {}
data "aws_region" "this" {}

locals {
  region = var.region == "" ? data.aws_region.this.name : var.region
  bucket = var.bucket == "" ? "prep-registration-${random_pet.this.id}" : var.bucket
  nid = var.network_name == "testnet" ? 80 : var.network_name == "mainnet" ? 1 : ""
  url = var.network_name == "testnet" ? "https://zicon.net.solidwallet.io" : "https://ctz.solidwallet.io/api/v3"

  ip = var.ip == null ? aws_eip.this.*.public_ip[0] : var.ip

  tags = merge(var.tags, {"Name" = "${var.network_name}-ip"})
}

resource "aws_eip" "this" {
  count = var.ip == null ? 1 : 0
  vpc = true
  tags = local.tags

  lifecycle {
    prevent_destroy = false
  }
}

resource "random_pet" "this" {
  length = 2
}

resource "aws_s3_bucket" "bucket" {
  bucket = local.bucket
  acl    = "public-read"

  website {
    index_document = "index.html"
  }

  policy = <<EOF
{
  "Id": "bucket_policy_site",
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "bucket_policy_site_main",
      "Action": [
        "s3:GetObject"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::${local.bucket}/*",
      "Principal": "*"
    }
  ]
}
EOF
}

########
# Images
########
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

resource aws_s3_bucket_object "logo_svg" {
  count = var.logo_svg == "" ? 0 : 1
  bucket = aws_s3_bucket.bucket.bucket
  key = basename(var.logo_svg)
  source = var.logo_svg
}

###########
# Templates
###########
resource template_file "details" {
  template = file("${path.module}/templates/details.json")
  vars = {
    logo_256 = "http://${aws_s3_bucket.bucket.website_endpoint}/${basename(var.logo_256)}"
    logo_1024 = "http://${aws_s3_bucket.bucket.website_endpoint}/${basename(var.logo_1024)}"
    logo_svg = "http://${aws_s3_bucket.bucket.website_endpoint}/${basename(var.logo_svg)}"

    steemit = var.steemit
    twitter = var.twitter
    youtube = var.youtube
    facebook = var.facebook
    github = var.github
    reddit = var.reddit
    keybase = var.keybase
    telegram = var.telegram
    wechat = var.wechat

    country = var.organization_country
    region = var.organization_city
    server_type = var.server_type

    ip = local.ip
  }
}

resource "template_file" "registration" {
  template = file("${path.module}/templates/registerPRep.json")
  vars = {
    name = var.organization_name
    country = var.organization_country
    city = var.organization_city
    email = var.organization_email
    website = var.organization_website

    details_endpoint = "http://${aws_s3_bucket.bucket.website_endpoint}/details.json"

    ip = local.ip
  }
  depends_on = [aws_s3_bucket.bucket]
}

resource template_file "preptools_config" {
  template = file("${path.module}/templates/preptools_config.json")
  vars = {
    nid = local.nid
    url = local.url
    keystore_path = var.keystore_path
  }
  depends_on = [aws_s3_bucket.bucket]
}

#################
# Persist objects
#################
resource "null_resource" "write_cfgs" {
  triggers = {
    build_always = timestamp()
  }

  provisioner "local-exec" {
    command = <<-EOF
echo '${template_file.preptools_config.rendered}' > ${path.module}/preptools_config.json
echo '${template_file.registration.rendered}' > ${path.module}/registerPRep.json
EOF
  }
}

resource "aws_s3_bucket_object" "details" {
  bucket = aws_s3_bucket.bucket.bucket
  key    = "details.json"
  content = template_file.details.rendered
}

##########
# Register
##########
// We need a way to store state of the registration in S3. If you register twice an error will pop up.
// We can surpress that error but then we can't conditionally make a resource that updates an object to track state of registration
// Instead we need to do it all with login in the null resource provision that first reads the object and whether it is true or not,
// call the register function to

resource aws_s3_bucket_object "register_bool" {
  bucket = aws_s3_bucket.bucket.bucket
  key = "register_bool"
}

data aws_s3_bucket_object "register_bool" {
  bucket = aws_s3_bucket.bucket.bucket
  key = "register_bool"
  depends_on = [aws_s3_bucket_object.register_bool]
}

//resource "null_resource" "registerPRep" {
//  count = data.aws_s3_bucket_object.register_bool.body == null ? 1 : 0
//
//  provisioner "local-exec" {
//    command = <<-EOF
//echo "Y" | preptools registerPRep --prep-json registerPRep.json -k ${var.keystore_path} -p ${var.keystore_password}
//EOF
//  }
//
//  depends_on = [aws_s3_bucket_object.details, null_resource.write_cfgs]
//}

resource null_resource "registerPRep" {
  provisioner "local-exec" {
    command = <<-EOF
#!/bin/bash
aws s3api get-object --bucket ${aws_s3_bucket.bucket.bucket} --key ${aws_s3_bucket_object.register_bool.key} ${path.module}/register_bool
register_state=`cat ${path.module}/register_bool`
if [ -z $register_state ]; then
  echo "Y" | preptools registerPRep --prep-json ${path.module}/registerPRep.json -k ${var.keystore_path} -p ${var.keystore_password}
else
  echo "already registered"
fi
EOF
  }
// Run this every time with logic trigger in call to see if the object has a true value in it
  triggers = {
    build_always = timestamp()
  }

  depends_on = [aws_s3_bucket_object.details, null_resource.write_cfgs]
}

resource "aws_s3_bucket_object" "register_bool_true" {
  bucket = aws_s3_bucket.bucket.bucket
  key = "register_bool"
  content = "true"
  depends_on = [null_resource.registerPRep]
}

##########
# set prep
##########

resource null_resource "setPRep" {
// This logic is broken.  We need another parameter to skip this step on first run
// Perhaps put a variable in an object setting the count of runs and only run this when count is >1
// Logic already in for if any resource changes, run set prep
//  provisioner "local-exec" {
//    command = <<-EOF
//#!/bin/bash
//aws s3api get-object --bucket ${aws_s3_bucket.bucket.bucket} --key ${aws_s3_bucket_object.register_bool.key} ${path.module}/register_bool
//register_state=`cat ${path.module}/register_bool`
//if [ -z $register_state ]; then
//  echo "Should not see this output ever - broken logic"
//else
//  echo "Setting prep"
//fi
//EOF
//}

  provisioner "local-exec" {
    command = <<-EOF
#!/bin/bash
echo "Y" | preptools setPRep --prep-json ${path.module}/registerPRep.json -k ${var.keystore_path} -p ${var.keystore_password}
EOF
  }

//  This makes the resource run when any of these change
  triggers = {
    details = template_file.details.rendered
    register = template_file.registration.rendered
    ip = var.ip == "" ? aws_eip.this.*.public_ip[0] : var.ip
  }

  depends_on = [aws_s3_bucket_object.register_bool_true]
}

