terraform {
  required_version = ">= 1.10"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.0"
    }
  }

  # State-ul sta in acelasi bucket S3 ca la TODO_CALENDAR (creat de bootstrap/ din acel repo), dar cu alta cheie.
  backend "s3" {
    bucket       = "todo-calendar-tf-state-034538845569"
    key          = "scoala/terraform.tfstate"
    region       = "eu-central-1"
    profile      = "todo-terraform"
    encrypt      = true
    use_lockfile = true
  }
}

provider "aws" {
  region  = var.region
  profile = "todo-terraform"

  default_tags {
    tags = { Project = "scoala" }
  }
}
