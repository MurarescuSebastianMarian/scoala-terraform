variable "region" {
  type    = string
  default = "eu-central-1"
}

variable "account_id" {
  type    = string
  default = "034538845569"
}

variable "table_name" {
  type    = string
  default = "scoala"
}

variable "function_name" {
  type    = string
  default = "scoala-api"
}

variable "site_bucket_name" {
  type    = string
  default = "scoala-fe-sebastian-2026"
}

variable "files_bucket_name" {
  type    = string
  default = "scoala-files-sebastian-2026"
}

variable "max_file_mb" {
  type    = number
  default = 25
}

variable "budget_limit_usd" {
  type    = number
  default = 5
}

# Emailul care primeste alertele de buget. Se seteaza in terraform.tfvars (ignorat de git).
variable "budget_email" {
  type = string
}

variable "github_owner" {
  type    = string
  default = "MurarescuSebastianMarian"
}

# GitHub pune ID-urile numerice in claim-ul "sub" (subiect imuabil): repo:<owner>@<owner_id>/<repo>@<repo_id>:ref:...
variable "github_owner_id" {
  type    = string
  default = "130826088"
}

variable "github_repo_id_be" {
  type    = string
  default = "1459699605"
}

variable "github_repo_id_fe" {
  type    = string
  default = "1459698390"
}
