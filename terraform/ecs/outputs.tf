output "ecs_task_execution_role_arn" {
    value = aws_iam_role.ecs_task_execution_role.arn
}

output "ecs_task_transform_arn" {
    value = aws_ecs_task_definition.ecs_task_transform.arn
}

output "ecs_cluster_arn" {
    value = aws_ecs_cluster.ecs_cluster.arn
}