#local variables to create 3 environments for the following resources
locals {
  environments = ["dev", "staging", "prod"]
}

resource "aws_s3_bucket" "buckets" {
  for_each = toset(local.environments)
  bucket   = "urlshortner-tfstate-${each.key}"
}

resource "aws_s3_bucket_versioning" "versioning" {
  for_each = toset(local.environments)
  bucket   = aws_s3_bucket.buckets[each.key].id

  versioning_configuration {
    status = "Enabled"
  }
}
resource "aws_s3_bucket_public_access_block" "public_access_block" {
  for_each = toset(local.environments)
  bucket   = aws_s3_bucket.buckets[each.key].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# ecr repositors
# identity provider for oidc
