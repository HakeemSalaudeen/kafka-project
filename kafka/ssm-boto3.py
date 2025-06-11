import boto3

ssm_client = boto3.client('ssm')

# Fetching parameters from AWS Systems Manager Parameter Store
confluent_cluster_api_key = ssm_client.get_parameter(
    Name="/kafka/confluent_cluster_api_key",
    WithDecryption=True
)
confluent_cluster_api_secret = ssm_client.get_parameter(
    Name="/kafka/confluent_cluster_api_secret",
    WithDecryption=True
)
# Fetching parameters for Confluent Cloud bootstrap servers
confluent_bootstrap_servers = ssm_client.get_parameter(
    Name="/kafka/confluent_bootstrap_servers",
    WithDecryption=True
)
