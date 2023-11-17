# Auto Scaling Policy
resource "aws_appautoscaling_target" "ecs_target" {
  max_capacity       = 4
  min_capacity       = 1
  resource_id        = "service/your-cluster/your-service"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "ecs_scaling_policy" {
  name               = "ecs-scaling-policy"
  scaling_target_id  = aws_appautoscaling_target.ecs_target.id
  adjustment_type    = "ChangeInCapacity"
  cooldown           = 300
  scaling_adjustment = 1
}
