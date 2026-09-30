terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
    axiom = {
      source  = "axiomhq/axiom"
      version = "~> 1.6.2"
    }
  }

  required_version = "~> 1.10"
}
