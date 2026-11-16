# Rolul Lambda: ce are voie sa faca backend-ul (doar tabelul si bucket-ul de fisiere).
resource "aws_iam_role" "lambda" {
  name = "scoala-api-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "lambda_dynamodb" {
  name = "scoala-dynamodb"
  role = aws_iam_role.lambda.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "dynamodb:GetItem", "dynamodb:PutItem", "dynamodb:UpdateItem", "dynamodb:DeleteItem",
        "dynamodb:Query", "dynamodb:Scan", "dynamodb:BatchWriteItem", "dynamodb:BatchGetItem",
      ]
      Resource = [aws_dynamodb_table.app.arn, "${aws_dynamodb_table.app.arn}/index/*"]
    }]
  })
}

# HeadObject cere s3:GetObject (acoperit aici). Fara s3:ListBucket, un obiect lipsa da 403 in loc de 404;
# codul (storage/s3.js exists) trateaza orice eroare ca "nu exista".
resource "aws_iam_role_policy" "lambda_files" {
  name = "scoala-files-s3"
  role = aws_iam_role.lambda.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["s3:PutObject", "s3:GetObject", "s3:DeleteObject"]
      Resource = "${aws_s3_bucket.files.arn}/*"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_logging" {
  role       = aws_iam_role.lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}
