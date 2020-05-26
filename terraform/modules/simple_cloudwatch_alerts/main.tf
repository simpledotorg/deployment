variable "ec2_sidekiq_server_id" {
  description = "The id of the sidekiq instance"
  type        = string
}

output "alert_arn" {
	value = aws_cloudwatch_metric_alarm.sidekiq_cpu.arn
}
