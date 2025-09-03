# CloudFront Origin Access Control
resource "aws_cloudfront_origin_access_control" "oac" {
  name                              = "${var.domain_name}-OAC"
  description                       = "Origin Access Control for ${var.domain_name}"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# CloudFront Distribution
resource "aws_cloudfront_distribution" "website" {
  aliases = [var.domain_name, "www.${var.domain_name}"]
  comment = "${var.domain_name} website distribution"
  enabled = true

  default_root_object = "index.html"
  http_version        = "http2and3"
  is_ipv6_enabled     = true
  price_class         = "PriceClass_100"

  origin {
    domain_name              = "${var.s3_bucket_name}.s3.${var.aws_region}.amazonaws.com"
    origin_id                = "S3-${var.s3_bucket_name}"
    origin_access_control_id = aws_cloudfront_origin_access_control.oac.id
  }

  # Default cache behavior for HTML files
  default_cache_behavior {
    allowed_methods          = ["GET", "HEAD", "OPTIONS"]
    cached_methods           = ["GET", "HEAD"]
    target_origin_id         = "S3-${var.s3_bucket_name}"
    compress                 = true
    viewer_protocol_policy   = "redirect-to-https"
    
    # Use managed cache policy for dynamic content (short cache)
    cache_policy_id            = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad" # CachingDisabled
    response_headers_policy_id = "67f7725c-6f97-4210-82d7-5512b31e9d03" # SecurityHeadersPolicy
  }

  # Cache behavior for CSS files
  ordered_cache_behavior {
    path_pattern             = "*.css"
    allowed_methods          = ["GET", "HEAD"]
    cached_methods           = ["GET", "HEAD"]
    target_origin_id         = "S3-${var.s3_bucket_name}"
    compress                 = true
    viewer_protocol_policy   = "redirect-to-https"
    cache_policy_id          = "2e54312d-136d-493c-8eb9-b001f22f67d2" # CachingOptimized
  }

  # Cache behavior for JS files
  ordered_cache_behavior {
    path_pattern             = "*.js"
    allowed_methods          = ["GET", "HEAD"]
    cached_methods           = ["GET", "HEAD"]
    target_origin_id         = "S3-${var.s3_bucket_name}"
    compress                 = true
    viewer_protocol_policy   = "redirect-to-https"
    cache_policy_id          = "2e54312d-136d-493c-8eb9-b001f22f67d2" # CachingOptimized
  }

  # Cache behavior for media files
  ordered_cache_behavior {
    path_pattern             = "media/*"
    allowed_methods          = ["GET", "HEAD"]
    cached_methods           = ["GET", "HEAD"]
    target_origin_id         = "S3-${var.s3_bucket_name}"
    compress                 = true
    viewer_protocol_policy   = "redirect-to-https"
    cache_policy_id          = "2e54312d-136d-493c-8eb9-b001f22f67d2" # CachingOptimized
  }

  # Custom error responses for SPA
  custom_error_response {
    error_code         = 403
    response_code      = 200
    response_page_path = "/index.html"
    error_caching_min_ttl = 300
  }

  custom_error_response {
    error_code         = 404
    response_code      = 200
    response_page_path = "/index.html"
    error_caching_min_ttl = 300
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate_validation.ssl_certificate.certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  tags = {
    Name = "${var.domain_name}-distribution"
  }
}