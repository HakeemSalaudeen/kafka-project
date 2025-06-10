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
  cloud_api_key    = aws_ssm_parameter.confluent_cloud_api_key.value
  cloud_api_secret = aws_ssm_parameter.confluent_cloud_api_secret.value
}

# Configure the AWS provider
# This provider is used to manage AWS resources, such as the Kafka cluster
provider "aws" {

  region = "eu-central-1"
}
