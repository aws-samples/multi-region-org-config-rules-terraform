# Enter values manually
terraform {
  backend "s3" {
    key            = ""
    encrypt        = true
    bucket         = ""
    region         = ""
    dynamodb_table = ""
  }
}
