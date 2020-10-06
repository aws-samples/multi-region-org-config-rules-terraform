##########
# S3 Variables
##########
variable "encryption_enabled" {
  type        = bool
  default     = true
  description = "When set to 'true' the resource will have AES256 encryption enabled by default"
}

variable "primary_region" {
  type        = string
  default     = "us-east-1"
  description = "Primary region used for condition with global resources for Config Rules."
}

##################
# Config Variables
#################
# Used as an parameters value for Manage Config Rules, specifically to enforce IAM Password Policy
# where the values are fed in as a mapped string.
variable "password_parameters" {
  description = "A map of strings in JSON format."
  type = map(string)
  default = {
    iam-password-policy = <<EOF
    { 
      "RequireUppercaseCharacters": "true",
      "RequireLowercaseCharacters": "true",
      "RequireSymbols": "true",
      "RequireNumbers": "true",
      "MinimumPasswordLength": "9",
      "PasswordReusePrevention": "5",
      "MaxPasswordAge": "90"
    }
      EOF
  }
}

variable "config_role_name" {
  description = "Name of Organization Config Role"
  default = "OrganizationConfigRole"
}

variable "aggregator_name" {
  description = "Name of Config Aggregator"
  default = "organization-aggregator"
}
