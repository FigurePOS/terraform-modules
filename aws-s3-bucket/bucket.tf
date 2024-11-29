# checkov:skip=CKV_AWS_144:Cross-region replication should be enabled.
# checkov:skip=CKV_AWS_145:KMS encryption by default.
# checkov:skip=CKV2_AWS_62:Notifications should be enabled.
resource "aws_s3_bucket" "bucket" {
  bucket = var.bucket_name

  force_destroy = var.force_destroy
}

resource "aws_s3_bucket_lifecycle_configuration" "lifecycle" {
  count  = var.lifecycle_enabled ? 1 : 0
  bucket = aws_s3_bucket.bucket.id

  rule {
    id     = var.lifecycle_config.id
    status = "Enabled"

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }

    expiration {
      days = var.lifecycle_config.expiration_days
    }
  }
}

resource "aws_s3_bucket_versioning" "versioning" {
  count  = var.versioning_enabled ? 1 : 0
  bucket = aws_s3_bucket.bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_logging" "logging" {
  count  = var.logging_enabled ? 1 : 0
  bucket = aws_s3_bucket.bucket.id

  target_bucket = var.logging_config.target_bucket
  target_prefix = var.logging_config.target_prefix
}

resource "aws_s3_bucket_policy" "policy" {
  count  = var.policy != null ? 1 : 0
  bucket = aws_s3_bucket.bucket.id

  policy = var.policy
}

resource "aws_s3_bucket_cors_configuration" "cors" {
  count  = var.cors_rule != null ? 1 : 0
  bucket = aws_s3_bucket.bucket.id

  cors_rule {
    allowed_headers = var.cors_rule.allowed_headers
    allowed_methods = var.cors_rule.allowed_methods
    allowed_origins = var.cors_rule.allowed_origins
    expose_headers  = var.cors_rule.expose_headers
    max_age_seconds = var.cors_rule.max_age_seconds
  }
}

resource "aws_s3_bucket_acl" "acl" {
  bucket = aws_s3_bucket.bucket.id

  acl = var.acl
}

resource "aws_s3_bucket_public_access_block" "public_access_block" {
  count  = var.public_access_block != null ? 1 : 0
  bucket = aws_s3_bucket.bucket.id

  block_public_acls       = var.public_access_block.block_public_acls
  block_public_policy     = var.public_access_block.block_public_policy
  ignore_public_acls      = var.public_access_block.ignore_public_acls
  restrict_public_buckets = var.public_access_block.restrict_public_buckets
}

resource "aws_s3_bucket_website_configuration" "website_configuration" {
  count = var.website_configuration_redirect != null || var.website_configuration_documents != null ? 1 : 0
  bucket = aws_s3_bucket.bucket.id

  dynamic "redirect_all_requests_to" {
    for_each = var.website_configuration_redirect != null ? [1] : []

    content {
      host_name = var.website_configuration_redirect
    }

  }

  dynamic "index_document" {
    for_each = var.website_configuration_redirect == null ? [1] : []

    content {
      suffix = var.website_configuration_documents.index
    }
  }

  dynamic "error_document" {
    for_each = var.website_configuration_redirect == null ? [1] : []
    content {
      key = var.website_configuration_documents.error
    }
  }
}
