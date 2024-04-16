//AWS Configuration
variable "access_key" {}
variable "secret_key" {}

variable "region" {
  default = "eu-west-2"
}

// Availability zones for the region
variable "az1" {
  default = "eu-west-2a"
}

variable "vpccidr" {
  default = "10.99.0.0/16"
}

variable "publiccidraz1" {
  default = "10.99.0.0/24"
}

variable "privatecidraz1" {
  default = "10.99.1.0/24"
}

variable "natcidraz1" {
  default = "10.99.99.0/24"
}

