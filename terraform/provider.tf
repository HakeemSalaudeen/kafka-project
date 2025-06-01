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
}

provider "aws" {
    
  #region = "us-east-1"
}



# terraform {
#   required_providers {
#     confluent = {
#       source = "confluentinc/confluent"
#       version = "2.30.0"
#     }
#   }
# }

# provider "confluent" {
#   # Configuration options
# }