# run in the cli after minikube start 
# to create a secret for boto3 credentials
# and region for the producer deployment
# replace the xxxxxxxxx with your actual AWS credentials
# and region, e.g., us-west-2

kubectl create secret generic aws-credentials \
  --from-literal=AWS_ACCESS_KEY_ID=xxxxxxxxxxxxxxxxxxxxxxx \
  --from-literal=AWS_SECRET_ACCESS_KEY=xxxxxxxxxxxxxxx \
  --from-literal=AWS_REGION=xxxxxx
