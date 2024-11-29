variable "bucket_name" {
  description = "The name of the S3 bucket"
  type        = string
}

variable "force_destroy" {
  description = "Whether to allow the bucket to be destroyed with items in it"
  type        = bool
  default     = false
}

variable "lifecycle_enabled" {
  description = "Whether to enable the lifecycle configuration"
  type        = bool
  default     = true
}

variable "lifecycle_config" {
  description = "The lifecycle configuration for the bucket"
  type = object({
    id              = optional(string, "expire-after-1y")
    enabled         = optional(bool, true)
    expiration_days = optional(number, 365)
  })
  default = {
    id              = "expire-after-1y"
    enabled         = true
    expiration_days = 365
  }
}

variable "versioning_enabled" {
  description = "Whether to enable versioning on the bucket"
  type        = bool
  default     = false
}

variable "logging_enabled" {
  description = "Whether to enable logging on the bucket"
  type        = bool
  default     = false
}

variable "logging_config" {
  description = "The logging configuration for the bucket"
  type = object({
    target_bucket = string
    target_prefix = optional(string, "")
  })
  default = null
}

variable "policy" {
  description = "The bucket policy"
  type        = string
  default     = null
}

variable "cors_rule" {
  description = "The CORS rule for the bucket"
  type = object({
    allowed_headers = optional(list(string), ["*"])
    allowed_methods = list(string)
    allowed_origins = list(string)
    expose_headers  = optional(list(string), [])
    max_age_seconds = optional(number, null)
  })
  default = null
}

variable "acl" {
  description = "The ACL for the bucket"
  type        = string
  default     = "private"
}

variable "public_access_block" {
  description = "The public access block configuration for the bucket"
  type = object({
    block_public_acls       = optional(bool, false)
    block_public_policy     = optional(bool, false)
    ignore_public_acls      = optional(bool, false)
    restrict_public_buckets = optional(bool, false)
  })
  default = null
}

variable "website_configuration_documents" {
  description = "The website configuration for the bucket"
  type = object({
    index = optional(string, "index.html")
    error = optional(string, "404.html")
  })
  default = null
}

variable "website_configuration_redirect" {
  description = "The website configuration for the bucket"
  type        = string
  default     = null
}
