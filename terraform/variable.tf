variable "confluent_cloud_api_key" {
  type        = string
  description = "API Key for Confluent Cloud"
  sensitive   = true
}

variable "confluent_cloud_api_secret" {
  type        = string
  description = "API Secret for Confluent Cloud"
  sensitive   = true
}

variable "environment_name" {
  type        = string
  default     = "kafka-project-env"
  description = "Name of the Confluent environment"
}

variable "kafka_cluster_name" {
  type        = string
  default     = "dev-cluster"
  description = "Kafka cluster name"
}

variable "region" {
  type        = string
  default     = "eu-central-1"
  description = "AWS region for Kafka cluster"
}

variable "kafka_topic_name" {
  type        = string
  default     = "faker-events-topic"
  description = "Kafka topic name"
}

variable "partitions" {
  type        = number
  default     = 1
  description = "Number of partitions for the topic"
}

# variable "kafka_rest_endpoint" {
#   description = "Kafka REST endpoint"
#   type        = string
# }
