resource "aws_cloudwatch_metric_alarm" "sidekiq_cpu" {
  alarm_name           = "Sidekiq Sandbox CPU Utilization is high"
  comparison_operator  = "GreaterThanOrEqualToThreshold"
  evaluation_periods   = "1"
  metric_name          = "CPUUtilization"
  namespace            = "AWS/EC2"
  period               = "60"
  statistic            = "Average"
  threshold            = "22.5"
  alarm_actions        = [ var.sns_arn ]
  ok_actions           = [ var.sns_arn ]

  dimensions = {
    InstanceId = "${var.ec2_sidekiq_server_id}"
  }
}
