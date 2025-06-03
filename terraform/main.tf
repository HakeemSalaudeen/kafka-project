# This Terraform configuration sets up a Confluent Kafka environment, cluster, topic, and service account.
resource "confluent_environment" "kafka-project" {
  display_name = var.environment_name
}

# Create a Confluent Kafka Cluster
# This cluster will be used to host the Kafka topics and manage the data streams
# The cluster is set to single zone availability in AWS region eu-central-1
resource "confluent_kafka_cluster" "kafka-cluster" {
  display_name = var.kafka_cluster_name
  availability = "SINGLE_ZONE"
  cloud        = "AWS"
  region       = var.region
  basic {}

  environment {
    id = confluent_environment.kafka-project.id
  }
}

# Create a Confluent Kafka Topic
# This topic will be used to produce and consume messages
resource "confluent_kafka_topic" "faker-events-topic" {
  depends_on = [confluent_api_key.kafka_api_key,
    confluent_service_account.faker-events-app-manager,
  confluent_kafka_acl.allow-create-topic]
  kafka_cluster {
    id = confluent_kafka_cluster.kafka-cluster.id
  }
  topic_name       = var.kafka_topic_name
  rest_endpoint    = confluent_kafka_cluster.kafka-cluster.rest_endpoint
  partitions_count = var.partitions
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
    id          = confluent_service_account.faker-events-app-manager.id
    api_version = confluent_service_account.faker-events-app-manager.api_version
    kind        = confluent_service_account.faker-events-app-manager.kind
  }

  managed_resource {
    id          = confluent_kafka_cluster.kafka-cluster.id
    api_version = confluent_kafka_cluster.kafka-cluster.api_version
    kind        = confluent_kafka_cluster.kafka-cluster.kind

    environment {
      id = confluent_environment.kafka-project.id
    }
  }
}

# Create a Confluent Service Account
# This service account will be used to manage the Kafka cluster and API keys
resource "confluent_service_account" "faker-events-app-manager" {
  display_name = "faker-events-app-manager"
  description  = "Service Account for faker-events cluster"
}


resource "confluent_kafka_acl" "allow-create-topic" {
  kafka_cluster {
    id = confluent_kafka_cluster.kafka-cluster.id
  }
  resource_type = "TOPIC"
  resource_name = var.kafka_topic_name
  rest_endpoint = confluent_kafka_cluster.kafka-cluster.rest_endpoint
  pattern_type  = "LITERAL"
  principal     = "User:${confluent_service_account.faker-events-app-manager.id}"
  host          = "*"
  operation     = "CREATE"
  permission    = "ALLOW"
}
