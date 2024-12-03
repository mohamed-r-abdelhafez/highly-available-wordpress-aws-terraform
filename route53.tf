resource "aws_route53_zone" "wordpress-zone" {
  name = var.route53_zone_name
}
resource "aws_route53_record" "cloudfront-record" {
  zone_id = aws_route53_zone.wordpress-zone.id
  name    = "${var.record_name}.${var.route53_zone_name}"
  type    = "A"
  alias {
    name                   = aws_cloudfront_distribution.wordpress-cloudfront.domain_name
    zone_id                = aws_cloudfront_distribution.wordpress-cloudfront.hosted_zone_id
    evaluate_target_health = "true"
  }
}
resource "aws_route53_record" "ipv6_cloudfront-record" {
  zone_id = aws_route53_zone.wordpress-zone.id
  name    = "${var.record_name}.${var.route53_zone_name}"
  type    = "AAAA"
  alias {
    name                   = aws_cloudfront_distribution.wordpress-cloudfront.domain_name
    zone_id                = aws_cloudfront_distribution.wordpress-cloudfront.hosted_zone_id
    evaluate_target_health = "true"
  }
}
