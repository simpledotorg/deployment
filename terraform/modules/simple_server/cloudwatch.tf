resource "aws_cloudwatch_metric_alarm" "sidekiq_cpu" {
  count                = var.cloudwatch_alerts_sns_arn == "" ? 0 : var.sidekiq_server_count
  alarm_name           = "Sidekiq-${count.index + 1} CPU Utilization is high [${var.deployment_name}]"
  comparison_operator  = "GreaterThanOrEqualToThreshold"
  evaluation_periods   = "1"
  metric_name          = "CPUUtilization"
  namespace            = "AWS/EC2"
  period               = "60"
  statistic            = "Average"
  threshold            = "22.5"
  alarm_actions        = [ var.cloudwatch_alerts_sns_arn ]
  ok_actions           = [ var.cloudwatch_alerts_sns_arn ]

  dimensions = {
    InstanceId = "${aws_instance.ec2_sidekiq_server[count.index].id}"
  }
}
