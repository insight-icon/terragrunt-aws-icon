terraform {
  source = "github.com/insight-infrastructure/terraform-aws-icon-user-data.git?ref=master"
}

include {
  path = find_in_parent_folders()
}

locals {}

inputs = {
  type = "prep"
  ssh_user = "ubuntu"
  prometheus_enabled = true
  consul_enabled = true
  driver_type = "standard"
}
