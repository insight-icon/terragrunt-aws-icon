terraform {
  source = "."
}

include {
  path = find_in_parent_folders()
}

dependencies {
  paths = ["../eks"]
}

dependency "eks" {
  config_path = "../eks"
}

//dependencies {
//  paths = ["../eks", "../service-accounts"]
//}

//dependency "eks" {
//  config_path = "../service-accounts"
//}

inputs = {
  cluster_id = dependency.eks.outputs.cluster_id
}
