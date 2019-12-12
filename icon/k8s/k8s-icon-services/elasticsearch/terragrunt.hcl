terraform {
  source = "."
}

include {
  path = find_in_parent_folders()
}

dependencies {
  paths = ["../eks"]
}

inputs = {
  cluster_id = dependency.eks.outputs.cluster_id
}
