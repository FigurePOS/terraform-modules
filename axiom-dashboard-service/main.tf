terraform {
  required_providers {
    axiom = {
      source = "axiomhq/axiom"
      # axiom_dashboard was added in v1.6.0 (main branch / GitHub release
      # 2026-03-05). It is not yet published to the public Terraform/OpenTofu
      # registry (latest registry version is 1.5.0 as of 2025-11-28). Until
      # axiomhq publishes 1.6.x to the registry, consumers must either use
      # `dev_overrides` pointing at a locally-built provider binary from the
      # axiomhq/terraform-provider-axiom repo, or wait for the registry
      # publish. See README.md for details.
      version = ">= 1.6.0"
    }
  }
}
