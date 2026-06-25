terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }

    datadog = {
      source  = "datadog/datadog"
      version = "~> 4.13"
    }
  }
}
