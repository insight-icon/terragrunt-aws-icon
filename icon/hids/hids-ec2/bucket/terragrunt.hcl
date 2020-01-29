terraform {
  source = "."
}

include {
  path = find_in_parent_folders()
}

locals {
  name = "hids-ec2"
}

inputs = {
  bucket_name = "wazuh-bucket-tmp"
}
