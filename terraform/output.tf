output "producer_repo_url" {
  value = aws_ecr_repository.producer-repo.repository_url
}

output "consumer_repo_url" {
  value = aws_ecr_repository.consumer-repo.repository_url
}
