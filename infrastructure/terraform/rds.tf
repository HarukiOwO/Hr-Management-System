resource "aws_db_subnet_group" "hr_db" {
  name       = "${var.project_name}-db-subnet-group"
  subnet_ids = module.vpc.database_subnets

  tags = {
    Name    = "${var.project_name}-db-subnet-group"
    Project = var.project_name
  }
}

resource "aws_security_group" "rds_sg" {
  name        = "hr-rds-sg"
  description = "Security group for HRMS PostgreSQL database"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description     = "PostgreSQL from Jenkins CI server"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.jenkins_sg.id]
  }

  ingress {
    description = "PostgreSQL from internal VPC subnet (EKS workers later)"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "${var.project_name}-rds-sg"
    Project = var.project_name
  }
}

resource "aws_db_instance" "hr_postgres" {
  identifier             = "hr-db-server"
  engine                 = "postgres"
  engine_version         = "15.7"        # Using stable Postgres 15 series
  instance_class         = "db.t3.micro" # Free-tier / low-cost eligible
  allocated_storage      = 20
  db_name                = "hrdb"
  username               = "hradmin"
  password               = var.db_password
  db_subnet_group_name   = aws_db_subnet_group.hr_db.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  multi_az               = false
  skip_final_snapshot    = true
  publicly_accessible    = false

  tags = {
    Name    = "${var.project_name}-rds-database"
    Project = var.project_name
  }
}
