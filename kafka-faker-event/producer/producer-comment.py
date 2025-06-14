import time
import boto3
from faker import Faker
from confluent_kafka import Producer
from datetime import datetime
import uuid                 # Importing uuid for unique event IDs

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

    msg.topic(): The name of the Kafka topic the message was sent to.
    msg.partition(): specific partition within that topic where the message was delivered
    msg.offset(): The offset of the message within that partition, A unique identifier for the message
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
topic = "faker-events"

while True:                                                             # Infinite loop to continuously produce events
    event = {
        "id": str(uuid.uuid4()),                                        # Generate a unique ID for each event, converts it to a string
        "name": faker.name(),                                           # Generate a random name with Faker
        "email": faker.email(),                                         # Generate a random email with Faker
        "timestamp": datetime.utcnow().isoformat()                      # generate the current UTC timestamp
    }
    producer.produce(
        topic,
        key=event["id"],
        value=str(event),
        callback=delivery_report
    )
    producer.flush()                                                     # Ensure all messages are sent before continuing
    time.sleep(5)                                                        # Sleep for 5 seconds before producing the next event
    print(f"Produced event: {event}")                                    # Print the produced event for debugging
