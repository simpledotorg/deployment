resource "aws_cloudwatch_metric_alarm" "sidekiq_cpu" {
  alarm_name           = "Sidekiq Sandbox CPU Utilization is high"
  comparison_operator  = "GreaterThanOrEqualToThreshold"
  evaluation_periods   = "1"
  metric_name          = "CPUUtilization"
  namespace            = "AWS/EC2"
  period               = "60"
  statistic            = "Average"
  threshold            = "22.5"
  alarm_actions        = [ "arn:aws:sns:ap-south-1:844366897011:cloudwatch-test-sns" ]
  ok_actions           = [ "arn:aws:sns:ap-south-1:844366897011:cloudwatch-test-sns" ]

  dimensions = {
    InstanceId = "${var.ec2_sidekiq_server_id}"
  }
}
