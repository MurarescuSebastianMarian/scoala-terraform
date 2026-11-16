# GitHub Actions -> AWS, fara chei (OIDC). Provider-ul OIDC exista deja in cont (creat de repo-ul
# TODO_CALENDAR_TERRAFORM), deci doar il citim; nu il gestionam aici.
data "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"
}

# --- BE: poate doar sa urce codul in functia Lambda scoala-api
resource "aws_iam_role" "deploy_be" {
  name = "github-deploy-scoala-be"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Federated = data.aws_iam_openid_connect_provider.github.arn }
      Action    = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          "token.actions.githubusercontent.com:sub" = "repo:${var.github_owner}/scoala-be:ref:refs/heads/main"
        }
      }
    }]
  })
}

resource "aws_iam_role_policy" "deploy_be" {
  name = "deploy-be"
  role = aws_iam_role.deploy_be.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["lambda:UpdateFunctionCode", "lambda:GetFunction", "lambda:GetFunctionConfiguration"]
      Resource = aws_lambda_function.api.arn
    }]
  })
}

# --- FE: poate doar sa urce in bucket-ul site-ului si sa invalideze CloudFront
resource "aws_iam_role" "deploy_fe" {
  name = "github-deploy-scoala-fe"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Federated = data.aws_iam_openid_connect_provider.github.arn }
      Action    = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          "token.actions.githubusercontent.com:sub" = "repo:${var.github_owner}/scoala-fe:ref:refs/heads/main"
        }
      }
    }]
  })
}

resource "aws_iam_role_policy" "deploy_fe" {
  name = "deploy-fe"
  role = aws_iam_role.deploy_fe.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      { Effect = "Allow", Action = "s3:ListBucket", Resource = aws_s3_bucket.site.arn },
      { Effect = "Allow", Action = ["s3:PutObject", "s3:DeleteObject"], Resource = "${aws_s3_bucket.site.arn}/*" },
      { Effect = "Allow", Action = "cloudfront:CreateInvalidation", Resource = aws_cloudfront_distribution.site.arn },
    ]
  })
}
