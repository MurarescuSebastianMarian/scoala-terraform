locals {
  s3_origin_id     = "scoala-site"
  lambda_origin_id = "scoala-api"

  # Politici gestionate de AWS (ID-uri fixe, la fel in orice cont).
  cache_policy_optimized      = "658327ea-f89d-4fab-a63d-7e88639e58f6" # CachingOptimized
  cache_policy_disabled       = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad" # CachingDisabled
  origin_request_all_but_host = "b689b0a8-53d0-40ab-baf2-68738e2966ac" # AllViewerExceptHostHeader
}

resource "aws_cloudfront_origin_access_control" "site" {
  name                              = "oac-scoala-fe"
  description                       = "OAC pentru bucket-ul FE scoala"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# Un singur domeniu pentru site si API (/api/*), deci cookie-ul de sesiune merge fara CORS.
# FE foloseste HashRouter, deci nu e nevoie de redirect 404 -> index.html.
resource "aws_cloudfront_distribution" "site" {
  enabled             = true
  is_ipv6_enabled     = true
  http_version        = "http2"
  price_class         = "PriceClass_100"
  default_root_object = "index.html"
  comment             = "scoala"

  origin {
    origin_id                = local.s3_origin_id
    domain_name              = aws_s3_bucket.site.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.site.id
  }

  origin {
    origin_id   = local.lambda_origin_id
    domain_name = replace(replace(aws_lambda_function_url.api.function_url, "https://", ""), "/", "")

    custom_origin_config {
      http_port                = 80
      https_port               = 443
      origin_protocol_policy   = "https-only"
      origin_ssl_protocols     = ["TLSv1.2"]
      origin_read_timeout      = 30
      origin_keepalive_timeout = 5
    }
  }

  default_cache_behavior {
    target_origin_id       = local.s3_origin_id
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    compress               = true
    cache_policy_id        = local.cache_policy_optimized
  }

  ordered_cache_behavior {
    path_pattern             = "/api/*"
    target_origin_id         = local.lambda_origin_id
    viewer_protocol_policy   = "redirect-to-https"
    allowed_methods          = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    cached_methods           = ["GET", "HEAD"]
    compress                 = true
    cache_policy_id          = local.cache_policy_disabled
    origin_request_policy_id = local.origin_request_all_but_host
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}
