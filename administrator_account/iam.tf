# -----------------------------------------------------------
# set up a role for the Configuration Recorder to use
# -----------------------------------------------------------

resource "aws_iam_role_policy_attachment" "config_org_policy_attach" {
  role       = aws_iam_role.config_role.name
  policy_arn = aws_iam_policy.config_org_policy.arn
}

resource "aws_iam_role_policy_attachment" "config_policy_attach" {
  role       = aws_iam_role.config_role.name
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/service-role/AWSConfigRole"
}

resource "aws_iam_role_policy_attachment" "read_only_policy_attach" {
  role       = aws_iam_role.config_role.name
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/ReadOnlyAccess"
}

resource "aws_iam_policy" "config_org_policy" {
  path        = "/"
  description = "IAM Policy for AWS Config"
  name        = "ConfigPolicy"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "config:GetOrganizationConfigRuleDetailedStatus",
        "config:Put*",
        "iam:GetPasswordPolicy",
        "organizations:ListAccounts",
        "organizations:DescribeOrganization",
        "organizations:ListAWSServiceAccessForOrganization",
        "organization:EnableAWSServiceAccess"
      ],
      "Effect": "Allow",
      "Resource": "*"
    },
    {
       "Effect": "Allow",
       "Action": ["s3:PutObject"],
       "Resource": ["arn:${data.aws_partition.current.partition}:s3:::config-bucket-${data.aws_caller_identity.current.account_id}-${data.aws_region.current.name}/AWSLogs/${data.aws_caller_identity.current.account_id}/*"],
       "Condition":
        {
          "StringLike":
            {
              "s3:x-amz-acl": "bucket-owner-full-control"
            }
        }
     },
     {
       "Effect": "Allow",
       "Action": ["s3:GetBucketAcl"],
       "Resource": "arn:${data.aws_partition.current.partition}:s3:::config-bucket-${data.aws_caller_identity.current.account_id}-${data.aws_region.current.name}"
     }
  ]
}
EOF
}

resource "aws_iam_role" "config_role" {
  name = var.config_role_name

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "config.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}