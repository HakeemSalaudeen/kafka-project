from confluent_kafka import Producer


def read_config():
    """
    Reads the client configuration from client.
    properties and returns it as a key-value map.
    """
    config = {}
    with open("client.properties") as fh:
        for line in fh:
            line = line.strip()
            if len(line) != 0 and line[0] != "#":
                parameter, value = line.strip().split('=', 1)
                config[parameter] = value.strip()
    return config


def produce(topic, config):
    """Creates a new producer instance and produces a sample message."""
    producer = Producer(config)

    # Produce a sample message
    key = "key"
    value = "value"
    producer.produce(topic, key=key, value=value)
    print(
        f"Produced message to topic {topic}: "
        f"key = {key:12} value = {value:12}"
    )

    # Send any outstanding or buffered messages to the Kafka broker
    producer.flush()


def main():
    config = read_config()
    topic = "sample_data_users"
    produce(topic, config)


if __name__ == "__main__":
    main()
