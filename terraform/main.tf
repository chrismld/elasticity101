terraform {
  required_version = ">= 0.12"
}

provider "aws" {
  profile = var.config.profile
  region  = var.config.region
}