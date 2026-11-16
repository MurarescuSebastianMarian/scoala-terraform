# DynamoDB: un singur tabel (PK + SK), ca la DynamoDB Local.
resource "aws_dynamodb_table" "app" {
  name         = var.table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "PK"
  range_key    = "SK"

  attribute {
    name = "PK"
    type = "S"
  }

  attribute {
    name = "SK"
    type = "S"
  }

  # Sesiunile expirate se sterg singure.
  ttl {
    attribute_name = "expiresAt"
    enabled        = true
  }

  # Contine toate datele aplicatiei: Terraform refuza sa-l stearga.
  lifecycle {
    prevent_destroy = true
  }
}
