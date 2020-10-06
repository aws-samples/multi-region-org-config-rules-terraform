# -----------------------------------------------------------
# set up a role for the Configuration Recorder to use
# -----------------------------------------------------------
resource "aws_iam_role" "config_role" {

  assume_role_policy = data.aws_iam_policy_document.config-role-document.json
}

resource "aws_iam_role_policy_attachment" "read_only_attach" {
  role       = aws_iam_role.config_role.name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

resource "aws_iam_role_policy_attachment" "config_role_attach" {
  role       = aws_iam_role.config_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSConfigRole"
}