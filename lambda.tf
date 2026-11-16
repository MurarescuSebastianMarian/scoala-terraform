# Zip minim, doar ca resursa sa aiba un "cod". Codul real il urca pipeline-ul din repo-ul BE
# (aws lambda update-function-code), iar Terraform il ignora (vezi ignore_changes).
data "archive_file" "placeholder" {
  type        = "zip"
  output_path = "${path.module}/placeholder.zip"

  source {
    content  = "exports.handler = async () => ({ statusCode: 200 });"
    filename = "src/lambda.js"
  }
}

resource "aws_cloudwatch_log_group" "api" {
  name              = "/aws/lambda/${var.function_name}"
  retention_in_days = 30
}

resource "aws_lambda_function" "api" {
  function_name = var.function_name
  role          = aws_iam_role.lambda.arn
  handler       = "src/lambda.handler"
  runtime       = "nodejs22.x"
  architectures = ["x86_64"]
  memory_size   = 512
  timeout       = 15

  filename         = data.archive_file.placeholder.output_path
  source_code_hash = data.archive_file.placeholder.output_base64sha256

  # Fara DYNAMODB_ENDPOINT (e doar pentru DynamoDB Local). Nu exista secrete in variabile.
  environment {
    variables = {
      TABLE_NAME  = aws_dynamodb_table.app.name
      STORAGE     = "s3"
      S3_BUCKET   = aws_s3_bucket.files.bucket
      NODE_ENV    = "production"
      MAX_FILE_MB = tostring(var.max_file_mb)
    }
  }

  logging_config {
    log_format = "Text"
    log_group  = aws_cloudwatch_log_group.api.name
  }

  lifecycle {
    ignore_changes = [filename, source_code_hash]
  }

  depends_on = [aws_iam_role_policy_attachment.lambda_logging]
}

# Adresa publica a API-ului (auth NONE: aplicatia are login propriu). Se acceseaza prin CloudFront la /api/*.
resource "aws_lambda_function_url" "api" {
  function_name      = aws_lambda_function.api.function_name
  authorization_type = "NONE"
  invoke_mode        = "BUFFERED"
}

resource "aws_lambda_permission" "url_invoke_function" {
  statement_id             = "FunctionURLAllowInvokeAction"
  function_name            = aws_lambda_function.api.function_name
  action                   = "lambda:InvokeFunction"
  principal                = "*"
  invoked_via_function_url = true
}

resource "aws_lambda_permission" "url_public_access" {
  statement_id           = "FunctionURLAllowPublicAccess"
  function_name          = aws_lambda_function.api.function_name
  action                 = "lambda:InvokeFunctionUrl"
  principal              = "*"
  function_url_auth_type = "NONE"
}
