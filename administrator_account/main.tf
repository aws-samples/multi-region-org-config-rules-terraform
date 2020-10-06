module "primary" {
  source = "./config"

  providers = {
    aws = aws
  }
}

module "secondary" {
  source = "./config"

  providers = {
    aws = aws.secondary
  }
}