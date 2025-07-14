terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.75, < 7.0"
    }

    datadog = {
      source  = "datadog/datadog"
      version = "~> 3.28"
    }
  }
}
