import boto3
from confluent_kafka import Consumer
from datetime import datetime
import uuid
import json


# Fetch secrets
def get_kafka_creds():
    ssm = boto3.client("ssm", region_name="eu-central-1")
    api_key = ssm.get_parameter(
        Name="/kafka/confluent_cluster_api_key",
        WithDecryption=True
    )['Parameter']['Value']
    api_secret = ssm.get_parameter(
        Name="/kafka/confluent_cluster_api_secret",
        WithDecryption=True
    )['Parameter']['Value']
    bootstrap_servers = ssm.get_parameter(
        Name="/kafka/confluent_bootstrap_servers",
        WithDecryption=True
    )['Parameter']['Value']
    return api_key, api_secret, bootstrap_servers


api_key, api_secret, bootstrap_servers = get_kafka_creds()

conf = {
    'bootstrap.servers': bootstrap_servers,
    'security.protocol': 'SASL_SSL',
    'sasl.mechanisms': 'PLAIN',
    'sasl.username': api_key,
    'sasl.password': api_secret,
    'group.id': 'faker-consumer-group',
    'auto.offset.reset': 'earliest'
}

consumer = Consumer(conf)
consumer.subscribe(['faker-events-topic'])

s3 = boto3.client('s3')
bucket_name = 'kafka-faker-events-bucket-demo'

try:
    while True:
        msg = consumer.poll(1.0)
        if msg is None:
            continue
        if msg.error():
            print(f"Consumer error: {msg.error()}")
            continue

        event = msg.value().decode('utf-8')
        try:
            json.loads(event)  # Validate JSON message
        except json.JSONDecodeError:
            print("Received non-JSON event, skipping.")
            continue
        key = (
            f"events/{datetime.utcnow().strftime('%Y-%m-%d_%H-%M-%S')}_"
            f"{uuid.uuid4()}.json"
        )
        s3.put_object(Bucket=bucket_name, Key=key, Body=event)
        print(f"Uploaded to S3: {key}")
except KeyboardInterrupt:
    print("Consumer interrupted by user.")
finally:
    consumer.close()
    print("Consumer closed.")
get_kafka_creds