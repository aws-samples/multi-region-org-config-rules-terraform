variable region {
  default = "us-east-1"
}

variable "source_account_number" {
  description = "Enter master organization account"
  type        = string
}

##########
# S3 Variables
##########
variable "encryption_enabled" {
  type        = bool
  default     = true
  description = "When set to 'true' the resource will have AES256 encryption enabled by default"
}