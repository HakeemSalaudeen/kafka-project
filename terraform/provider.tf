terraform {
  required_providers {
    confluent = {
      source  = "confluentinc/confluent"
      version = "2.30.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "5.87.0"
    }
  }
}

provider "confluent" {
  # Configuration options
  cloud_api_key    = var.confluent_cloud_api_key
  cloud_api_secret = var.confluent_cloud_api_secret
}

provider "aws" {

  region = "eu-central-1"
}
