# ================================================================
# ECS Module - Outputs
# 
# This file defines outputs from the ECS module.
# ================================================================

output "ecs_task_execution_role_arn" {
    value = aws_iam_role.ecs_task_execution_role.arn
}

output "ecs_task_transform_arn" {
    value = aws_ecs_task_definition.ecs_task_transform.arn
}

output "ecs_task_validate_arn" {
    value = aws_ecs_task_definition.ecs_task_validate.arn
}

output "ecs_cluster_arn" {
    value = aws_ecs_cluster.ecs_cluster.arn
}

output "ecs_sg_id" {
    value = aws_security_group.ecs_sg.id
}