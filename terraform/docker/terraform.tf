terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.15.0"
    }

    random = {
      source  = "hashicorp/random"
      version = "~> 3.1.0"
    }

    tls = {
      source  = "hashicorp/tls"
      version = "~> 3.4.0"
    }

    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 2.24.0"
    }
  }

  required_version = "~> 1.3"
}
