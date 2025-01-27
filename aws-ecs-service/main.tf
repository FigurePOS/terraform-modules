terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.34"
    }

    datadog = {
      source = "datadog/datadog"
      version = ">= 3.31"
    }
  }
}
