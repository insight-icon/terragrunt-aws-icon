variable "bucket" {
  type = string
  default = ""
}

variable "network_name" {
  type = string
  default = "testnet"
}


// ------------------Registration

variable "organization_name" {
  type = string
  default = ""
}
variable "organization_country" {
  type = string
  default = ""
}
variable "organization_email" {
  type = string
  default = ""
}
variable "organization_city" {
  type = string
  default = ""
}
variable "organization_website" {
  type = string
  default = ""
}

// ------------------Details

variable "logo_256" {
  type = string
  default = ""
}
variable "logo_1024" {
  type = string
  default = ""
}
variable "logo_svg" {
  type = string
  default = ""
}
variable "steemit" {
  type = string
  default = ""
}
variable "twitter" {
  type = string
  default = ""
}
variable "youtube" {
  type = string
  default = ""
}
variable "facebook" {
  type = string
  default = ""
}
variable "github" {
  type = string
  default = ""
}
variable "reddit" {
  type = string
  default = ""
}
variable "keybase" {
  type = string
  default = ""
}
variable "telegram" {
  type = string
  default = ""
}
variable "wechat" {
  type = string
  default = ""
}
variable "server_type" {
  type = string
  default = "cloud"
}

variable "region" {
  type = string
  default = ""
}
variable "ip" {
  type = string
  default = ""
}

//------------------

variable "keystore_path" {
  type = string
}

variable "keystore_password" {
  type = string
}