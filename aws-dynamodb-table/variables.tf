variable "table_name" {
  type        = string
  description = "The name of the table, this needs to be unique within a region."
}

variable "hash_key" {
  type        = string
  description = "The attribute to use as the hash (partition) key."
}

variable "range_key" {
  type        = string
  description = "The attribute to use as the range (sort) key."
  default     = ""
}

variable "attributes" {
  type = list(object({
    name = string
    type = string
  }))
  description = "List of attributes with name and type for the DynamoDB table."
}

variable "global_secondary_indexes" {
  type = list(object({
    name            = string
    hash_key        = string
    range_key       = optional(string)
    projection_type = string
    read_capacity   = optional(number)
    write_capacity  = optional(number)
  }))
  description = "List of global secondary indexes to create on the DynamoDB table"
  default     = []
}

variable "ttl_attribute_name" {
  type        = string
  description = "The name of the TTL attribute for DynamoDB, if TTL is needed."
  default     = ""
}