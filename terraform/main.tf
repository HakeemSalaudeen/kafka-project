# This Terraform configuration sets up a Confluent Kafka environment, cluster, topic, and service account.
resource "confluent_environment" "kafka-project" {
  display_name = var.environment_name
}

# resource "confluent_environment" "kafka-projectb" {
#   display_name = "kafka-projectb"
# }

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
  depends_on = [confluent_api_key.cluster_api_key,
    confluent_service_account.kafka-cluster-app-manager
    ,confluent_role_binding.app-manager-kafka-cluster-admin
  ]
  kafka_cluster {
    id = confluent_kafka_cluster.kafka-cluster.id
  }
  topic_name       = var.kafka_topic_name
  rest_endpoint    = confluent_kafka_cluster.kafka-cluster.rest_endpoint
  partitions_count = var.partitions
  credentials {
    key    = aws_ssm_parameter.confluent_cluster_api_key.value
    secret = aws_ssm_parameter.confluent_cluster_api_secret.value
  }
}


# Create a Confluent API Key for the Kafka Cluster
# This API key will be used to authenticate with the Kafka cluster
resource "confluent_api_key" "cluster_api_key" {
  display_name = "cluster-events-api-key"
  owner {
    id          = confluent_service_account.kafka-cluster-app-manager.id
    api_version = confluent_service_account.kafka-cluster-app-manager.api_version 
    kind        = confluent_service_account.kafka-cluster-app-manager.kind
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
resource "confluent_service_account" "kafka-cluster-app-manager" {
  display_name = "kafkacluster-app-manager"
  description  = "Service Account for faker-events cluster"
}

resource "confluent_role_binding" "app-manager-kafka-cluster-admin" {
  principal   = "User:${confluent_service_account.kafka-cluster-app-manager.id}"
  role_name   = "CloudClusterAdmin"
  crn_pattern = confluent_kafka_cluster.kafka-cluster.rbac_crn
}