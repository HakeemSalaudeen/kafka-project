import json
import time
import boto3
from faker import Faker
from confluent_kafka import Producer
import os

faker = Faker()

# Fetch Kafka credentials from AWS SSM
def get_kafka_creds():
    ssm = boto3.client("ssm", region_name="eu-central-1")
    api_key = ssm.get_parameter(Name="/kafka/confluent_cloud_api_key", WithDecryption=True)['Parameter']['Value']
    api_secret = ssm.get_parameter(Name="/kafka/confluent_cloud_api_secret", WithDecryption=True)['Parameter']['Value']
    bootstrap_servers = ssm.get_parameter(Name="/kafka/confluent_cloud_bootstrap_servers", WithDecryption=True)['Parameter']['Value']
    return api_key, api_secret, bootstrap_servers

api_key, api_secret, bootstrap_servers = get_kafka_creds()

conf = {
    'bootstrap.servers': bootstrap_servers,  # Update this from Confluent Cloud
    'security.protocol': 'SASL_SSL',
    'sasl.mechanisms': 'PLAIN',
    'sasl.username': api_key,
    'sasl.password': api_secret,
}

producer = Producer(conf)

def generate_event():
    return {
        "user_id": faker.uuid4(),
        "name": faker.name(),
        "email": faker.email(),
        "signup_ts": faker.iso8601(),
        "location": faker.city()
    }

def delivery_report(err, msg):
    if err is not None:
        print('Delivery failed:', err)
    else:
        print(f'Message delivered to {msg.topic()} [{msg.partition()}]')

topic = "faker-events"

while True:
    event = generate_event()
    producer.produce(topic, json.dumps(event).encode('utf-8'), callback=delivery_report)
    producer.flush()
    time.sleep(2)
