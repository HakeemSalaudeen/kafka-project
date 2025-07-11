# Kafka Project

A production-ready event streaming pipeline using Confluent Cloud Kafka, Python, Docker, Kubernetes, and AWS. 

This project demonstrates how to generate synthetic events,stream them to Kafka, consume and process them, and store results in AWS S3 bucket. Infrastructure is provisioned with Terraform, and CI/CD is managed via GitHub Actions using:

- Python producer (generates fake events using Faker)
- Python consumer (reads from Kafka, writes to AWS S3)
- Kafka cluster hosted on Confluent Cloud
- Secrets managed in AWS SSM Parameter Store
- Dockerized apps deployed to Docker hub and Kubernetes (Minikube)
- CI/CD with GitHub Actions
- Infrastructure provisioned with Terraform

---

## Table of Contents

- [Architecture Overview](#architecture-overview)
- [Features](#features)
- [Tech Stack](#tech-stack)
- [Project Structure](#project-structure)
- [Setup & Deployment](#setup--deployment)
  - [Infrastructure Provisioning (Terraform)](#infrastructure-provisioning-terraform)
  - [Docker Images](#docker-images)
  - [Kubernetes Deployment](#kubernetes-deployment)
  - [Secrets Management](#secrets-management)
- [Producer Service](#producer-service)
- [Consumer Service](#consumer-service)
- [CI/CD Pipeline](#cicd-pipeline)
- [Testing & Linting](#testing--linting)
- [Best Practices](#best-practices)
- [Troubleshooting](#troubleshooting)
- [References](#references)

---

## Architecture Overview

```
[Faker Producer (Python)] --> [Confluent Cloud Kafka Topic] --> [Consumer (Python)] --> [AWS S3 Bucket]
```

- **Producer**: Generates synthetic events using Faker and streams them to a Kafka topic.
- **Kafka**: Managed by Confluent Cloud, provisioned via Terraform.
- **Consumer**: Reads events from Kafka, validates, and uploads them to AWS S3.
- **CI/CD**: Automated build, test, and deployment using GitHub Actions.
- **Kubernetes**: Container orchestration for scalable deployments.

---

## Features

- **Synthetic Event Generation** with Faker
- **Secure Kafka Authentication** using Confluent Cluster API Keys
- **Event Validation & Processing**
- **AWS S3 Integration** for persistent storage
- **Infrastructure as Code** with Terraform
- **Containerization** with Docker
- **Orchestration** with Kubernetes
- **Secrets Management** using Kubernetes Secrets
- **Automated CI/CD** with GitHub Actions

---

## Tech Stack

- **Python (Faker, Boto3)**
- **Apache Kafka (confluent-kafka)**
- **AWS S3, SSM**
- **Docker**
- **Kubernetes**
- **Terraform**
- **GitHub Actions**

---

## Project Structure

```
kafka-project/
├── kafka-faker-event/
│   ├── producer/
│   │   ├── producer.py
│   │   ├── requirements.txt
│   │   └── Dockerfile
│   ├── consumer/
│   │   ├── consumer.py
│   │   ├── requirements.txt
│   │   └── Dockerfile
│   └── ...
├── kubernetes/
│   ├── producer/producer-deployment.yml
│   ├── consumer/consumer-deployment.yml
│   └── secret.sh
├── terraform/
│   ├── main.tf
│   ├── ecr.tf
│   ├── output.tf
│   └── ...
├── .github/workflows/ci-cd.yaml
├── requirements.txt
├── .gitignore
└── README.md
```

---

## Setup & Deployment

### Infrastructure Provisioning (Terraform)

1. **Configure AWS and Confluent Cloud credentials** in your environment.
2. **Initialize and apply Terraform:**
   ```sh
   cd terraform
   terraform init
   terraform apply
   ```
   This will provision:
   - Confluent Kafka environment, cluster, topic, and API keys
   - AWS ECR repositories for Docker images

3. **SSM Parameter Store**: Cluster API keys and bootstrap servers are stored in AWS SSM for secure retrieval by your Python apps.

### Docker Images

- **Producer**: `akym001/my-kafka-producer`
- **Consumer**: `akym001/my-kafka-consumer`

Build locally:
```sh
docker build -t my-kafka-producer ./kafka-faker-event/producer
docker build -t my-kafka-consumer ./kafka-faker-event/consumer
```

### Kubernetes Deployment

1. **Create AWS credentials secret:**
   ```sh
   kubectl create secret generic aws-credentials \
     --from-literal=AWS_ACCESS_KEY_ID=xxx \
     --from-literal=AWS_SECRET_ACCESS_KEY=xxx \
     --from-literal=AWS_REGION=xxx
   ```
2. **Deploy Producer and Consumer:**
   ```sh
   kubectl apply -f kubernetes/producer/producer-deployment.yml
   kubectl apply -f kubernetes/consumer/consumer-deployment.yml
   ```
3. **Verify:**
   ```sh
   kubectl get pods
   kubectl logs deployment/kafka-consumer
   kubectl logs deployment/kafka-producer
   ```

### Secrets Management

- AWS credentials are injected into containers via Kubernetes secrets.
- Kafka credentials are securely fetched from AWS SSM Parameter Store at runtime.

---

## Producer Service

- **Location:** `kafka-faker-event/producer/producer.py`
- **Function:** Generates random user events and streams them to Kafka.
- **Key Points:**
  - Uses Confluent Cluster API Key/Secret from SSM.
  - Serializes events as JSON.
  - Handles delivery reports and errors.
  - Topic name: `faker-events-topic`

**Sample Code:**
```python
event = {
    "id": str(uuid.uuid4()),
    "name": faker.name(),
    "email": faker.email(),
    "timestamp": datetime.utcnow().isoformat()
}

{
  "event_id": "cd0123ff-7fa1-4988-b47c-12345678",
  "name": "John Doe",
  "email": "john@example.com",
  "timestamp": "2025-06-11T08:30:00Z"
}

producer.produce(
    topic,
    key=event["id"],
    value=json.dumps(event),
    callback=delivery_report
)
```

---

## Consumer Service

- **Location:** `kafka-faker-event/consumer/consumer.py`
- **Function:** Consumes events from Kafka, validates JSON, and uploads to S3.
- **Key Points:**
  - Uses Confluent Cluster API Key/Secret from SSM.
  - Validates each event as JSON before processing.
  - Stores events in S3 bucket: `kafka-faker-events-bucket-demo`
  - Handles errors gracefully.

**Sample Code:**
```python
event = msg.value().decode('utf-8')
try:
    json.loads(event)
except json.JSONDecodeError:
    print("Received non-JSON event, skipping.")
    continue
s3.put_object(Bucket=bucket_name, Key=key, Body=event)
```

---

## CI/CD Pipeline

- **Location:** `.github/workflows/ci-cd.yaml`
- **Features:**
  - Automated linting with flake8
  - Terraform format checks
  - Docker image build and push to Docker Hub
  - (Optional) ECR push 

**Sample Workflow:**
```yaml
- name: Build Producer Image
  run: |
    docker build -t kafka-producer ./producer
    docker tag kafka-producer:latest ${{ secrets.DOCKER_USERNAME }}/kafka-producer:latest
    docker push ${{ secrets.DOCKER_USERNAME }}/kafka-producer:latest
```

---

## Checks & Linting

- **Terraform Checks:** Use `terraform fmt` for standard terraform formats.
- **Python Linting:** Use `flake8` for code style checks.


---

## Best Practices

- **Use Confluent Cluster API Keys** for Kafka authentication (not Confluent Cloud API keys).
- **Store secrets securely** in AWS SSM and Kubernetes secrets.
- **Validate all incoming events** before processing.
- **Use resource requests/limits** in Kubernetes for stability.
- **Automate builds and deployments** with CI/CD.
- **Monitor logs** for authentication errors and message delivery issues.

---

## Troubleshooting Practices

- **SASL Authentication Error:**  
  Ensure you are using the correct Confluent Cluster API key/secret from SSM. Double-check parameter names and values.
- **No Messages in Topic:**  
  Confirm producer is running and using the correct topic name (`faker-events-topic`).
- **Consumer Not Processing Events:**  
  Check for JSON validation errors in logs. Ensure S3 bucket exists and credentials are correct.
- **Docker Build Issues:**  
  Ensure `requirements.txt` matches your Python code dependencies.


---

## References

- [Confluent Cloud Documentation](https://docs.confluent.io/cloud/current/index.html)
- [AWS SSM Parameter Store](https://docs.aws.amazon.com/systems-manager/latest/userguide/systems-manager-parameter-store.html)
- [Kubernetes Secrets](https://kubernetes.io/docs/concepts/configuration/secret/)
- [GitHub Actions](https://docs.github.com/en/actions)
- [Terraform](https://www.terraform.io/docs)

---

*For any issues or feature requests, please open an issue in this repository.*