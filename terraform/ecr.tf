resource "aws_ecr_repository" "producer-repo" {
  name                 = "kafka-producer-repo"
  image_tag_mutability = "MUTABLE"
  force_delete         = true

  encryption_configuration {
    encryption_type = "AES256"
  }
}

resource "aws_ecr_repository" "consumer-repo" {
  name                 = "kafka-consumer-repo"
  image_tag_mutability = "MUTABLE"
  force_delete         = true

  encryption_configuration {
    encryption_type = "AES256"
  }
}
