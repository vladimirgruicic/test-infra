# CloudWatch Alarms
resource "aws_cloudwatch_metric_alarm" "ecs_memory_alarm" {
  alarm_name          = "ecs-memory-alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "MemoryReservation"
  namespace           = "AWS/ECS"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "ECS Memory Utilization High"
  alarm_actions       = ["your_auto_scaling_policy_arn"]
}
