output "alb_sg" {
  value = aws_security_group.alb.id
}

output "ecs_task_sg" {
  value = aws_security_group.ecs_task.id
}

output "postgres_sg" {
  value = aws_security_group.postgres.id
}

output "elasticache_sg" {
  value = aws_security_group.elasticache.id
}

output "vpc_endpoints_sg" {
  value = aws_security_group.vpc_endpoints.id
}
