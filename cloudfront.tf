resource "aws_cloudfront_origin_access_control" "s3_oac" {
  name                              = "S3OAC"
  description                       = "Origin Access Control for S3"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "wordpress-cloudfront" {
  origin {
    domain_name = aws_s3_bucket.static-content.bucket_domain_name
    origin_id   = "S3-Static-Origin"
    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_control.s3_oac.id
    }
  }
  origin {
    domain_name = aws_lb.wordpress-alb.dns_name
    origin_id   = "ALB-Dynamic-Origin"
    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "match-viewer"
      origin_ssl_protocols   = ["TLSv1", "TLSv1.1", "TLSv1.2"]
    }
  }
  default_cache_behavior {
    target_origin_id       = "ALB-Dynamic-Origin"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    cached_methods         = ["GET", "HEAD", "OPTIONS"]
    forwarded_values {
      query_string = true
      headers      = ["Authorization"]
      cookies {
        forward = "all"
      }
    }
    min_ttl     = 0
    default_ttl = 3600
    max_ttl     = 86400
  }

  ordered_cache_behavior {
    path_pattern           = "/static/*"
    target_origin_id       = "S3-Static-Origin"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    min_ttl     = 0
    default_ttl = 86400
    max_ttl     = 31536000
  }

  enabled             = true
  price_class         = var.price_class
  is_ipv6_enabled     = true
  comment             = "CloudFront distribution for static and dynamic content"
  default_root_object = "index.html"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  tags = {
    Environment = var.env
    Owner       = "WordPress Project"
  }
}

