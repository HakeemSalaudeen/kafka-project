terraform {
  cloud {

    organization = "kafka_project"

    workspaces {
      name = "kafka_project"
    }
  }
}