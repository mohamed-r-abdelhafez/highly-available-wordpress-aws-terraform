resource "aws_s3_bucket" "static-content" {
  bucket        = "wordpress-static-content"
  force_destroy = true
  tags = {
    Name        = "Wordpress Bucket"
    Environment = var.env
  }
}
resource "aws_s3_bucket_acl" "bucket_acl" {
  bucket = aws_s3_bucket.static-content.id
  acl    = "private"
}
resource "aws_s3_bucket_versioning" "versioning_bucket" {
  bucket = aws_s3_bucket.static-content.id
  versioning_configuration {
    status = "Enabled"
  }
}
data "aws_iam_policy_document" "allow-cloud-front" {
  statement {
    effect    = "allow"
    actions   = ["s3:GetObject"]
    resources = [aws_s3_bucket.static-content.arn, "${aws_s3_bucket.static-content.arn}/*"]
    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }
    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [aws_cloudfront_distribution.wordpress-cloudfront.arn]
    }
  }

}
resource "aws_s3_bucket_policy" "static-content-policy" {
  bucket = aws_s3_bucket.static-content.id
  policy = data.aws_iam_policy_document.allow-cloud-front.json
}