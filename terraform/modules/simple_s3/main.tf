variable "bucket_name" {
  type        = string
  description = "Name of s3 bucket to be used for storing logs"
}

resource "aws_s3_bucket" "logs_bucket" {
  bucket = var.bucket_name
}

resource "aws_iam_group" "s3_users" {
  name = "s3-users"
}

resource "aws_iam_user" "s3_user" {
  name = "s3-user"
}

resource "aws_iam_group_membership" "s3_user_membership" {
  name  = "s3-user-membership"
  users = [aws_iam_user.s3_user.name]
  group = aws_iam_group.s3_users.name
}

resource "aws_iam_group_policy_attachment" "s3_permission" {
  group      = aws_iam_group.s3_users.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_access_key" "s3_user_access_key" {
  user = aws_iam_user.s3_user.name
}

output "user_access_key_id" {
  value = aws_iam_access_key.s3_user_access_key.id
}

output "user_secret_key" {
  value     = aws_iam_access_key.s3_user_access_key.secret
  sensitive = true
}

