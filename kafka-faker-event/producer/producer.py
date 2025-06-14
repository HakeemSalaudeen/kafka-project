import time
import boto3
from faker import Faker
from confluent_kafka import Producer
from datetime import datetime
import uuid
import json

faker = Faker()


# Fetch secrets
def get_kafka_creds():
    ssm = boto3.client("ssm", region_name="eu-central-1")
    api_key = ssm.get_parameter(
        Name="/kafka/confluent_cloud_api_key",
        WithDecryption=True
    )['Parameter']['Value']
    api_secret = ssm.get_parameter(
        Name="/kafka/confluent_cloud_api_secret",
        WithDecryption=True
    )['Parameter']['Value']
    bootstrap_servers = ssm.get_parameter(
        Name="/kafka/confluent_cloud_bootstrap_servers",
        WithDecryption=True
    )['Parameter']['Value']
    return api_key, api_secret, bootstrap_servers


def delivery_report(err, msg):
    """
    Called once for each message produced to indicate delivery result
    :param err: Error, if any. None if successful.
    :param msg: provide information about the original message that failed.
        """
    if err is not None:
        print(f"Message delivery failed to topic: {err}")
    else:
        print(
            f"Message delivered to {msg.topic()}, [{msg.partition()}] "
            f"at offset {msg.offset()}"
        )


api_key, api_secret, bootstrap_servers = get_kafka_creds()

conf = {
    'bootstrap.servers': bootstrap_servers,
    'security.protocol': 'SASL_SSL',
    'sasl.mechanisms': 'PLAIN',
    'sasl.username': api_key,
    'sasl.password': api_secret
}

producer = Producer(conf)
topic = "faker-events-topic"

try:
    while True:
        event = {
            "id": str(uuid.uuid4()),
            "name": faker.name(),
            "email": faker.email(),
            "timestamp": datetime.utcnow().isoformat()
        }
        producer.produce(
            topic,
            key=event["id"],
            value=json.dumps(event),
            callback=delivery_report
        )
        print(f"Produced event: {event}")
        time.sleep(5)
except KeyboardInterrupt:
    print("Producer interrupted by user.")
except Exception as e:
    print(f"An error occurred: {e}")
finally:
    producer.flush()
    print("Producer has been flushed and is exiting.")
    print("Exiting producer.")
