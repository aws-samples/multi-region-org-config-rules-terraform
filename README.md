# Terraform Multi-Region Organization Config Rules

## Installation

Instructions for installing the Terraform software can be found [here](https://learn.hashicorp.com/terraform/getting-started/install.html).

## Pre-requisites

It is best practice to store Terraform state files in S3 as well as use DynamoDB for locking of the state file to consistency 
and prevent state locking. 

1) First create a DynamoDB table in the same region that the Terraform stack is being initialized and created in. Per Hashicorp's [documentation](https://www.terraform.io/docs/backends/types/s3.html), the only requirement when creating the DynamoDB table is to
make sure that it has a Primary Key value of "LockID".

2) Create the S3 bucket. This will store the state file when a 'terraform apply' is executed after backend initialization has succeeded.

3) Modify the administrator_account/backend.tf and secondary_account/backend.tf, respectively.
  a) Adjust the following parameters:

  | Name | Description | 
  |------|-------------|
  | key | This will be the path of your Terraform state file. |
  | bucket | The Amazon S3 bucket that the Terraform state file will be deployed to and referenced. |
  | region | The region of the S3 bucket |
  | dynamodb_table | The name of a DynamoDB table to use for state locking and consistency. The table must have a primary key named LockID. If not present, locking will be disabled. |

```

    terraform {
        backend "s3" {
            key            = ENTER_DESIRED_STATE_FILE_NAME
            bucket         = ENTER_S3_BUCKET
            region         = ENTER_REGION
            dynamodb_table = ENTER_DYNAMODB_TABLE
        }
    }
```

When the correct values are put in place for each parameter, and you run a terraform init, this will initialize the backend on the first run. The Terraform state file will create once resources are created. On subsequent initialization (terraform init) runs, a connection will be made to the state file. 

## Running Terraform stack

### Setup secondary accounts

To run this solution, we will want to go to the secondary account folder and run the initialization. Your output should look similar to the following:

```
14:27 $ terraform init
Initializing modules...

Initializing the backend...

Initializing provider plugins...

The following providers do not have any version constraints in configuration,
so the latest version was installed.

To prevent automatic upgrades to new major versions that may contain breaking
changes, it is recommended to add version = "..." constraints to the
corresponding provider blocks in configuration, with the constraint strings
suggested below.

* provider.aws: version = "~> 2.66"

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
```

From there, once our current working directory is initialized, we can run a ```terraform plan``` and ```terraform apply```.
This will start to process and create all the resources, along with our authorizaiton as indicated below:

```
module.us-east-1.aws_config_delivery_channel.config_channel: Creation complete after 3s [id=default]
module.us-east-1.aws_config_configuration_recorder_status.config_recorder_status: Creating...
module.us-east-2.aws_config_configuration_recorder_status.config_recorder_status: Creation complete after 1s [id=default]
module.us-east-1.aws_config_configuration_recorder_status.config_recorder_status: Creation complete after 1s [id=default]

Apply complete! Resources: 17 added, 0 changed, 0 destroyed.
```

### Setup Config administrator account

Once this is complete, we will want to navigate to the administrator folder and run through the same process. When the stack has completed creating, we'll see the output of the following:

```
module.secondary.aws_config_organization_managed_rule.s3_public_access_organization_config_rules: Still creating... [2m20s elapsed]
module.secondary.aws_config_organization_managed_rule.s3_public_access_organization_config_rules: Still creating... [2m30s elapsed]
module.secondary.aws_config_organization_managed_rule.s3_public_access_organization_config_rules: Creation complete after 2m35s [id=s3-account-level-public-access-blocks]

Apply complete! Resources: 30 added, 0 changed, 0 destroyed.

Outputs:

config_aggregator_arn = arn:aws:config:us-east-1:725369550382:config-aggregator/config-aggregator-j0ushwgk
```

## Summary

Terraform is broken down into three main components:

- Providers
- Variables
- Resources

We will look at how these components work together in a Terraform configuration. 


### Providers

Terraform is used to create, manage, and update infrastructure resources. In this case, it's used to create the Amazon Simple Storage Service (Amazon S3) buckets, AWS Organization Conig rules along with other infrastructure types that are represented as a resource in Terraform. 

For the administrator and secondary accounts, the Terraform configuration works off of aliases and the region for each provider is set in ```provider.tf```

Administrator account:

```
provider aws {
  region = "us-east-1" 
}

provider aws {
  alias  = "secondary"
  region = "us-east-2"
}
```

Secondary account(s):

```
provider aws {
  alias                   = "secondary-account-virginia"
  region                  = "us-east-1" 
  profile                 = "secondary_account"
}

provider aws {
  alias                   = "secondary-account-ohio"
  region                  = "us-east-2"
  profile                 = "secondary_account"
}
```

This will tie into the modules that are created for each account, respectively.

Administrator account:

```
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
```

If the region needs to be set at a different region from this configuration, modify the ```provider.tf``` file. If additional regions need to be configured, add another provider and module as necessary.

## Variables

In addition to the environment variables that we can use in our provider, Terraform allows us to explicitly declare variables, which we can use to make our config dynamic. In the current configuration, we declare four variables for the administrator account, two for the secondary account(s).

The syntax for a variable is as follows:

```
variable “[variable name]” {
    default     = “[optional]”
    description = “[optional]”
  type        = “string|int|list|map”
```

- default: Allows you to specify a default value for a variable.
- description: Allows you to add a human-readable description that describes the purpose of the variable.
- type: Defines the type of the variable.

Here are the variables for the administrator account configuration:

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| password_parameters | Parameters for the IAM Account Password policy | map(string) | `"Default in configuration"` | yes |
| config_role_name | Name of the IAM Role used for AWS Config | string | `"OrganizationConfigRole"` | yes |
| aggregator_name | Name of the AWS Config aggregator | string | `"organization-aggregator"` | yes |
| encryption_enabled | Determines if server-side encryption is enabled for S3 Bucket | boolean | `"true"` | yes |
| primary_region | Primary region used for condition with global resources for Config Rules. | boolean | `"true"` | yes |

Here are the variables for the secondary account configuration:

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| source_account_number | Delegated Administrator account | string | `""` | yes |
| encryption_enabled | Determines if server-side encryption is enabled for S3 Bucket | boolean | `"true"` | yes |

Variables can be automatically set in the ```variables.tf``` file or through the ```terraform.tfvars```. 

## Resources

Resources in this configuration are the componenet of our infrastructure. It could serve as a Virtual Private Cloud, S3 bucket, or a virtual machine. In this solution, most of our resources serve as Organization Config Rules.

In the administrator account folder, most of our resources are set in the config module, particularly in the ```config.tf``` file.

Most of the rules are configured as follows:

```
# AWS Config Rule that checks whether users of your AWS account require a multi-factor authentication (MFA) 
# device to sign in with root credentials.
resource "aws_config_organization_managed_rule" "root_account_mfa_organization_config_rules" {
  count = data.aws_region.current.name == "us-east-1" ? 1 : 0
  depends_on        = [
    aws_config_configuration_recorder.config_recorder
  ]

  name              = "root-account-mfa-enabled"
  rule_identifier   = "ROOT_ACCOUNT_MFA_ENABLED"
}


# AWS Config Rule that checks whether the required public access block settings are configured from account level. 
# The rule is only NON_COMPLIANT when the fields set below do not match the corresponding fields in the configuration 
# item.
resource "aws_config_organization_managed_rule" "s3_public_access_organization_config_rules" {
  depends_on        = [
    aws_config_configuration_recorder.config_recorder
  ]

  name              = "s3-account-level-public-access-blocks"
  rule_identifier   = "S3_ACCOUNT_LEVEL_PUBLIC_ACCESS_BLOCKS"
}

```

Terraform has its own version of for loops. In this case, we have IAM specific rules that are being created. Since IAM is a global service, it doesn't make sense to have duplicate monitoring in both us-east-1 and us-east-2 (as our example regions). This is where ```count``` comes in, we specific that if our region is us-east-1, create one resource of this type. If it isn't us-east-1, don't create a resource.

## Caveats

This solution will create an AWS Config Recorder and Delivery channel. These resources are created per region. If you're using an AWS Landing Zone or AWS Control Tower solution, this script will have to be modified as you're only allowed one of each of the aforementioned resources within a region. Otherwise, the Terraform stack on deployment will fail. 

The Organization Config Rules are used as an example and any rules can be added or removed based on user needs. 

## Maintainer

For support please contact:

- lechange@amazon.com