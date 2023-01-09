output "foundry_image" {
  depends_on = [
    aws_ecs_task_definition.foundry_task
  ]
  value = local.foundry_image
}

output "foundry_service" {
  value = aws_ecs_service.foundry_service
}

output "foundry_container_definitions" {
  value = {
    arn                = aws_ecs_task_definition.foundry_task.arn
    family             = aws_ecs_task_definition.foundry_task.family
    memory             = aws_ecs_task_definition.foundry_task.memory
    cpu                = aws_ecs_task_definition.foundry_task.memory
    execution_role_arn = aws_ecs_task_definition.foundry_task.execution_role_arn
    task_role_arn      = aws_ecs_task_definition.foundry_task.task_role_arn
    runtime_platform   = aws_ecs_task_definition.foundry_task.runtime_platform
  }
}