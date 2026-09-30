terraform {
  required_providers {
    datadog = {
      source  = "datadog/datadog"
      version = "~> 4.13"
    }
  }

  required_version = "~> 1.10"
}
