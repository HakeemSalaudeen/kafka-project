# This Terraform configuration sets up a Confluent Kafka environment, cluster, topic, and service account.
resource "confluent_environment" "kafka-project" {
  display_name = "kafka-project"
}

# Create a Confluent Kafka Cluster
# This cluster will be used to host the Kafka topics and manage the data streams
# The cluster is set to single zone availability in AWS region eu-central-1
resource "confluent_kafka_cluster" "kafka-cluster" {
  display_name = "dev-cluster"
  availability = "SINGLE_ZONE"
  cloud        = "AWS"
  region       = "eu-central-1"
  basic {}

  environment {
    id = confluent_environment.kafka-project.id
  }
}

# Create a Confluent Kafka Topic
# This topic will be used to produce and consume messages
resource "confluent_kafka_topic" "faker-events-topic" {
  kafka_cluster {
    id = confluent_kafka_cluster.kafka-cluster.id
  }
  topic_name       = "faker-events-topic"
  rest_endpoint    = confluent_kafka_cluster.kafka-cluster.rest_endpoint
  partitions_count = 1
  credentials {
    key    = confluent_api_key.kafka_api_key.id
    secret = confluent_api_key.kafka_api_key.secret
  }
}


# Create a Confluent API Key for the Kafka Cluster
# This API key will be used to authenticate with the Kafka cluster
resource "confluent_api_key" "kafka_api_key" {
  display_name = "faker-events-api-key"
  owner {
    id          = confluent_service_account.kafka-sa.id
    api_version = confluent_service_account.kafka-sa.api_version
    kind        = confluent_service_account.kafka-sa.kind
  }

  depends_on = [confluent_kafka_cluster.kafka]
}

# Create a Confluent Service Account
# This service account will be used to manage the Kafka cluster and API keys
resource "confluent_service_account" "kafka-sa" {
  display_name = "faker-events-sa"
  description  = "Service Account for faker-events"
}