data "aws_iam_policy_document" "ec2-assume-role-policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}
data "aws_iam_policy_document" "parameter-store-document" {
  statement {
    effect    = "Allow"
    actions   = ["ssm:GetParameters", "ssm:GetParameter", "ssm:GetParametersByPath"]
    resources = ["*"]
  }
}
data "aws_iam_policy_document" "s3" {
  statement {
    effect    = "allow"
    actions   = ["s3:PutObject", "s3:GetObject", "s3:ListBucket"]
    resources = [aws_s3_bucket.static-content.arn, "${aws_s3_bucket.static-content.arn}/*"]
  }
}
resource "aws_iam_policy" "s3-policy-document" {
  policy = data.aws_iam_policy_document.s3.json
}
resource "aws_iam_policy" "parameter_store_policy" {
  policy = data.aws_iam_policy_document.parameter-store-document.json
}
resource "aws_iam_role" "wordpress-iam-role" {
  name               = "wordpress-iam-role"
  assume_role_policy = data.aws_iam_policy_document.ec2-assume-role-policy.json
}
resource "aws_iam_policy_attachment" "parameter-store-attach" {
  name       = "parameter-store-attach"
  roles      = [aws_iam_role.wordpress-iam-role.name]
  policy_arn = aws_iam_policy.parameter_store_policy.arn
}
resource "aws_iam_policy_attachment" "s3-attach" {
  name       = "s3-attach"
  roles      = [aws_iam_role.wordpress-iam-role.name]
  policy_arn = aws_iam_policy.s3-policy-document.arn

}

resource "aws_iam_instance_profile" "wordpress-instance-profile" {
  name = "wordpress-instance-profile"
  role = aws_iam_role.wordpress-iam-role.name
}


