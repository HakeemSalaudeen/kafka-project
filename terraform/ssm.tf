resource "aws_ssm_parameter" "confluent_cloud_api_key" {
  name        = "/kafka/confluent_cloud_api_key"
  type        = "SecureString"
  value       = var.confluent_cloud_api_key
  description = "Confluent Cloud API Key"
  #overwrite = true
}

resource "aws_ssm_parameter" "confluent_cloud_api_secret" {
  name        = "/kafka/confluent_cloud_api_secret"
  type        = "SecureString"
  value       = var.confluent_cloud_api_secret
  description = "Confluent Cloud API Secret"
 # overwrite = true
}

resource "aws_ssm_parameter" "confluent_cluster_api_secret" {
  name        = "/kafka/confluent_cluster_api_secret"
  type        = "SecureString"
  value       = confluent_api_key.cluster_api_key.secret
  description = "Confluent Cluster API Secret"
 # overwrite = true
}

resource "aws_ssm_parameter" "confluent_cluster_api_key" {
  name        = "/kafka/confluent_cluster_api_key"
  type        = "SecureString"
  value       = confluent_api_key.cluster_api_key.id
  description = "Confluent Cluster API Key"
 # overwrite = true
}


