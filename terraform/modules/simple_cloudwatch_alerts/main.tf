variable "ec2_sidekiq_server_id" {
  description = "The id of the sidekiq instance"
  type        = string
}

variable "sns_arn" {
  description = "The ARN of the SNS topic from which messages will be sent"
  type        = string
}
