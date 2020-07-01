resource "aws_cloudwatch_metric_alarm" "average_webserver_cpu" {
  count                     = var.enable_cloudwatch_alerts ? var.server_count : 0
  alarm_name                = "High CPU on Webserver-${count.index + 1} [${var.deployment_name}]"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/EC2"
  period                    = "60"
  statistic                 = "Average"
  threshold                 = "22.5"
  alarm_actions             = [var.cloudwatch_alerts_sns_arn]
  ok_actions                = [var.cloudwatch_alerts_sns_arn]
  insufficient_data_actions = [var.cloudwatch_alerts_sns_arn]
  treat_missing_data        = "breaching"

  dimensions = {
    InstanceId = aws_instance.ec2_simple_server[count.index].id
  }
}

resource "aws_cloudwatch_metric_alarm" "sidekiq_cpu" {
  count                     = var.enable_cloudwatch_alerts ? var.sidekiq_server_count : 0
  alarm_name                = "High CPU on Sidekiq-${count.index + 1} [${var.deployment_name}]"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/EC2"
  period                    = "60"
  statistic                 = "Average"
  threshold                 = "65"
  alarm_actions             = [var.cloudwatch_alerts_sns_arn]
  ok_actions                = [var.cloudwatch_alerts_sns_arn]
  insufficient_data_actions = [var.cloudwatch_alerts_sns_arn]
  treat_missing_data        = "breaching"

  dimensions = {
    InstanceId = aws_instance.ec2_sidekiq_server[count.index].id
  }
}

resource "aws_cloudwatch_metric_alarm" "master_database_cpu" {
  count                     = var.enable_cloudwatch_alerts ? 1 : 0
  alarm_name                = "High CPU on master DB [${var.deployment_name}]"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/RDS"
  period                    = "60"
  statistic                 = "Average"
  threshold                 = "78"
  alarm_actions             = [var.cloudwatch_alerts_sns_arn]
  ok_actions                = [var.cloudwatch_alerts_sns_arn]
  insufficient_data_actions = [var.cloudwatch_alerts_sns_arn]
  treat_missing_data        = "breaching"

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.simple-database[0].id
  }
}

resource "aws_cloudwatch_metric_alarm" "standby_database_cpu" {
  count                     = var.create_database_replica && var.enable_cloudwatch_alerts ? 1 : 0
  alarm_name                = "High CPU on standby DB [${var.deployment_name}]"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/RDS"
  period                    = "60"
  statistic                 = "Average"
  threshold                 = "30"
  alarm_actions             = [var.cloudwatch_alerts_sns_arn]
  ok_actions                = [var.cloudwatch_alerts_sns_arn]
  insufficient_data_actions = [var.cloudwatch_alerts_sns_arn]
  treat_missing_data        = "breaching"

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.replica_simple_database[0].id
  }
}

resource "aws_cloudwatch_metric_alarm" "elb_5xx_timeouts" {
  count               = var.load_balancer_arn_suffix != "" && var.enable_cloudwatch_alerts ? 1 : 0
  alarm_name          = "High 5xx / timeouts on [${var.deployment_name}]"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "HTTPCode_Target_5XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = "60"
  statistic           = "Average"
  threshold           = "5"
  alarm_actions       = [var.cloudwatch_alerts_sns_arn]
  ok_actions          = [var.cloudwatch_alerts_sns_arn]
  treat_missing_data  = "notBreaching"

  dimensions = {
    LoadBalancer = var.load_balancer_arn_suffix
    TargetGroup  = aws_lb_target_group.simple_server_target_group.arn_suffix
  }
}
