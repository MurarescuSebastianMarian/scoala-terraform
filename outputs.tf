output "site_url" {
  value = "https://${aws_cloudfront_distribution.site.domain_name}"
}

output "cloudfront_distribution_id" {
  value = aws_cloudfront_distribution.site.id
}

output "lambda_function_name" {
  value = aws_lambda_function.api.function_name
}

output "lambda_function_url" {
  value = aws_lambda_function_url.api.function_url
}

output "site_bucket" {
  value = aws_s3_bucket.site.bucket
}

output "files_bucket" {
  value = aws_s3_bucket.files.bucket
}

output "deploy_role_be_arn" {
  value = aws_iam_role.deploy_be.arn
}

output "deploy_role_fe_arn" {
  value = aws_iam_role.deploy_fe.arn
}
