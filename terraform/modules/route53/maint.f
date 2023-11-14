# Route 53 Domain
resource "aws_route53_zone" "my_domain" {
  name = "your_domain_name"
}

# DNS Record for CloudFront
resource "aws_route53_record" "cloudfront_dns" {
  zone_id = aws_route53_zone.my_domain.zone_id
  name    = "your_domain_name"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.my_cloudfront.domain_name
    zone_id               = aws_cloudfront_distribution.my_cloudfront.hosted_zone_id
    evaluate_target_health = false
  }
}
