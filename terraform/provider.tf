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
  cloud_api_key    = confluent_api_key.kafka_api_key.id
  cloud_api_secret = confluent_api_key.kafka_api_key.secret
}

provider "aws" {

  #region = "us-east-1"
}
