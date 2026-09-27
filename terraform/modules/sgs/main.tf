#alb inbound 80/443
resource "aws_security_group" "alb" {
  name        = "alb_sg"
  description = "Allow ports 80/443 inbound traffic and all outbound traffic"
  vpc_id      = var.vpc_id

  tags = merge(var.common_tags, { Name = "${var.common_tags.Project}-alb-sg" })
}

resource "aws_vpc_security_group_ingress_rule" "alb_port_80" {
  #checkov:skip=CKV_AWS_260:Port 80 open intentionally to redirect http to https at the alb
  security_group_id = aws_security_group.alb.id
  description       = "Allow inbound HTTP from the internet (redirected to HTTPS)"
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "alb_port_443" {
  security_group_id = aws_security_group.alb.id
  description       = "Allow inbound HTTPS from the internet"
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "alb_allow_all_outbound" {
  security_group_id = aws_security_group.alb.id
  description       = "Allow all outbound traffic from ALB"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

#ECS task

resource "aws_security_group" "ecs_task" {
  name        = "ecs_task_sg"
  description = "Allow inbound HTTP traffic from the ALB only"
  vpc_id      = var.vpc_id

  tags = merge(var.common_tags, { Name = "${var.common_tags.Project}-ecs-task-sg" })
}

resource "aws_vpc_security_group_ingress_rule" "ecs_port_8080" {
  security_group_id            = aws_security_group.ecs_task.id
  description                  = "Allow inbound traffic from ALB to the api service on port 8080"
  referenced_security_group_id = aws_security_group.alb.id
  from_port                    = 8080
  ip_protocol                  = "tcp"
  to_port                      = 8080
}

resource "aws_vpc_security_group_ingress_rule" "ecs_port_8081" {
  security_group_id            = aws_security_group.ecs_task.id
  description                  = "Allow inbound traffic from ALB to the dashboard service on port 8081"
  referenced_security_group_id = aws_security_group.alb.id
  from_port                    = 8081
  ip_protocol                  = "tcp"
  to_port                      = 8081
}

resource "aws_vpc_security_group_egress_rule" "ecs_task_allow_all_outbound" {
  security_group_id = aws_security_group.ecs_task.id
  description       = "Allow all outbound traffic from ECS tasks"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

#RDS
resource "aws_security_group" "postgres" {
  name        = "postgres_sg"
  description = "Allow inbound Postgres traffic from ECS tasks only"
  vpc_id      = var.vpc_id

  tags = merge(var.common_tags, { Name = "${var.common_tags.Project}-postgres-sg" })
}

resource "aws_vpc_security_group_ingress_rule" "postgres" {
  security_group_id            = aws_security_group.postgres.id
  description                  = "Allow inbound Postgres traffic from ECS tasks"
  referenced_security_group_id = aws_security_group.ecs_task.id
  from_port                    = 5432
  to_port                      = 5432
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "postgres_allow_all_outbound" {
  security_group_id = aws_security_group.postgres.id
  description       = "Allow all outbound traffic from RDS"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

# ElastiCache
resource "aws_security_group" "elasticache" {
  name        = "elasticache_sg"
  description = "Allow inbound Redis traffic from ECS tasks only"
  vpc_id      = var.vpc_id

  tags = merge(var.common_tags, { Name = "${var.common_tags.Project}-elasticache-sg" })
}

resource "aws_vpc_security_group_ingress_rule" "elasticache" {
  security_group_id            = aws_security_group.elasticache.id
  description                  = "Allow inbound Redis traffic from ECS tasks"
  referenced_security_group_id = aws_security_group.ecs_task.id
  from_port                    = 6379
  to_port                      = 6379
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "elasticache_allow_all_outbound" {
  security_group_id = aws_security_group.elasticache.id
  description       = "Allow all outbound traffic from ElastiCache"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

# VPC Endpoints (Interface) - Allow ECS tasksto reach AWS services pivately
resource "aws_security_group" "vpc_endpoints" {
  name        = "vpc_endpoints_sg"
  description = "Allow inbound HTTPS traffic from ECS tasks only"
  vpc_id      = var.vpc_id

  tags = merge(var.common_tags, { Name = "${var.common_tags.Project}-vpc-endpoints-sg" })
}

resource "aws_vpc_security_group_ingress_rule" "vpc_endpoints_https" {
  security_group_id            = aws_security_group.vpc_endpoints.id
  description                  = "Allow inbound HTTPS traffic from ECS tasks to VPC endpoints"
  referenced_security_group_id = aws_security_group.ecs_task.id
  from_port                    = 443
  to_port                      = 443
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "vpc_endpoints_allow_all_outbound" {
  security_group_id = aws_security_group.vpc_endpoints.id
  description       = "Allow all outbound traffic from VPC endpoints"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}
