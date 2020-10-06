# Providers for secondary account
provider aws {
  alias  = "secondary-account-virginia"
  region = "us-east-1" 
  profile                 = "secondary_account"
}

provider aws {
  alias  = "secondary-account-ohio"
  region = "us-east-2"
  profile                 = "secondary_account"
}
