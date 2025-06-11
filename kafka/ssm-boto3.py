import boto3

ssm_client = boto3.client('ssm')

# Fetch parameters from SSM
api_key = ssm_client.get_parameter(
    Name="/kafka/confluent_cluster_api_key",
    WithDecryption=True
)['Parameter']['Value']

api_secret = ssm_client.get_parameter(
    Name="/kafka/confluent_cluster_api_secret",
    WithDecryption=True
)['Parameter']['Value']

bootstrap_servers = ssm_client.get_parameter(
    Name="/kafka/confluent_bootstrap_servers",
    WithDecryption=True
)['Parameter']['Value']

# Read existing config.properties
config_path = "kafka/config.properties"
with open(config_path, "r") as f:
    lines = f.readlines()

# Update relevant lines
with open(config_path, "w") as f:
    for line in lines:
        if line.startswith("sasl.username="):
            f.write(f"sasl.username={api_key}\n")
        elif line.startswith("sasl.password="):
            f.write(f"sasl.password={api_secret}\n")
        elif line.startswith("bootstrap.servers="):
            f.write(f"bootstrap.servers={bootstrap_servers}\n")
        else:
            f.write(line)
