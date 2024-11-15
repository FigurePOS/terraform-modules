terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.75"
    }

    datadog = {
      source  = "datadog/datadog"
      version = "~> 3.28"
    }
  }
}
