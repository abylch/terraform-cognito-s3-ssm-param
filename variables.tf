variable "region" {
    default =  "us-west-1"
}
variable "availability_zone" {
    description = "The  availability zone"
    type        = map(string)
    default = {
        a = "us-west-1a"
        c = "us-west-1c"
  }
}

variable "acc" {
    default = "404057943866"
}

variable "api_name" {
    default = "api-01"
}

variable "stage_name" {
    default = "stage-01"
}

variable "user_pool_name" {
    default = "user-pool-01"
}

variable "user_pool_client_name" {
    default = "user-pool-client-01"
}

variable "identity_pool_name" {
    default = "identity-pool-01"
}

variable "authorizer_name" {
    default = "authorizer-01"
}

variable "lambda_function_name" {
    default = "lambda_function"
}

variable "route53_zone_id" {
    default = "Z000523520EIRHBODB1EF"
}

variable "aws_dynamodb_table_name" {
    default = "user-table-01"
}

variable "bucket_name" {
    default = "bucket-commit-01"
}

variable "acl_value" {
    default = "private"
}

# Cors allow_headers
variable "allow_headers" {
  description = "Allow headers"
  type        = list(string)

  default = [
    "Authorization",
    "Content-Type",
    "X-Amz-Date",
    "X-Amz-Security-Token",
    "X-Api-Key",
  ]
}

# Cors allow_methods
variable "allow_methods" {
  description = "Allow methods"
  type        = list(string)

  default = [
    "OPTIONS",
    "HEAD",
    "GET",
    "POST",
    "PUT",
    "PATCH",
    "DELETE",
  ]
}

# Cors Allow_origin
variable "allow_origin" {
  description = "Allow origin"
  type        = string
  default     = "*"
}

