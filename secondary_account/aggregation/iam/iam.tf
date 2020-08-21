resource "aws_iam_role" "config_role" {
  name = "ConfigRecorderRole"

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

resource "aws_iam_policy" "s3_config_org_policy" {
  path        = "/"
  description = "S3ConfigOrganizationPolicy"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
       "Effect": "Allow",
       "Action": ["s3:PutObject"],
       "Resource": ["arn:aws:s3:::config-bucket-${data.aws_caller_identity.current.account_id}-${data.aws_region.current.name}/*"],
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
       "Resource": "arn:aws:s3:::config-bucket-${data.aws_caller_identity.current.account_id}-${data.aws_region.current.name}"
     }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "config_s3_policy_attach" {
  role       = aws_iam_role.config_role.name
  policy_arn = aws_iam_policy.s3_config_org_policy.arn
}

resource "aws_iam_role_policy_attachment" "read_only_attachment" {
  role       = aws_iam_role.config_role.name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

resource "aws_iam_role_policy_attachment" "config_attachment" {
  role       = aws_iam_role.config_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSConfigRole"
}
