output "details_endpoint" {
  value = "http://${aws_s3_bucket.bucket.website_endpoint}/details.json"
}

output "details_values" {
  value = data.template_file.details.rendered
}

output "registration_json" {
  value = data.template_file.registration.rendered
}

output "ip" {
  value = var.ip == "" ? concat(aws_eip.this.*.public_ip, [""])[0] : var.ip
}

output "network_name" {
  value = var.network_name
}

output "registration_command" {
  value = <<-EOF
preptools registerPRep \
--url ${local.url} \
--nid ${local.nid} \
%{if var.keystore_path != ""}--keystore ${var.keystore_path}%{ endif } \
%{if var.organization_name != ""}--name "${var.organization_name}"%{ endif } \
%{if var.organization_country != ""}--country "${var.organization_country}"%{ endif } \
%{if var.organization_city != ""}--city "${var.organization_city}"%{ endif } \
%{if var.organization_email != ""}--email "${var.organization_email}"%{ endif } \
%{if var.organization_website != ""}--website "${var.organization_website}"%{ endif } \
--details http://${aws_s3_bucket.bucket.website_endpoint}/details.json \
--p2p-endpoint "${local.ip}:7100"
EOF
}

output "update_registration_command" {
  value = <<-EOF
preptools setPRep \
--url ${local.url} \
--nid ${local.nid} \
%{if var.keystore_path != ""}--keystore ${var.keystore_path}%{ endif } \
%{if var.organization_name != ""}--name "${var.organization_name}"%{ endif } \
%{if var.organization_country != ""}--country "${var.organization_country}"%{ endif } \
%{if var.organization_city != ""}--city "${var.organization_city}"%{ endif } \
%{if var.organization_email != ""}--email "${var.organization_email}"%{ endif } \
%{if var.organization_website != ""}--website "${var.organization_website}"%{ endif } \
--details http://${aws_s3_bucket.bucket.website_endpoint}/details.json \
--p2p-endpoint "${local.ip}:7100"
EOF
}