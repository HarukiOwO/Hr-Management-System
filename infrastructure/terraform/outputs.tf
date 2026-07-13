output "vpc_id" {
  value       = module.vpc.vpc_id
  description = "The ID of the VPC"
}

output "public_subnets" {
  value       = module.vpc.public_subnets
  description = "List of IDs of public subnets"
}

output "private_subnets" {
  value       = module.vpc.private_subnets
  description = "List of IDs of private subnets"
}

output "database_subnets" {
  value       = module.vpc.database_subnets
  description = "List of IDs of database subnets"
}

output "nat_gateway_ips" {
  value       = module.vpc.nat_public_ips
  description = "Public Elastic IPs created for AWS NAT Gateway"
}

output "jenkins_public_ip" {
  value       = aws_instance.jenkins.public_ip
  description = "Public IP address of the Jenkins CI server on EC2"
}

output "rds_endpoint" {
  value       = aws_db_instance.hr_postgres.endpoint
  description = "Connection endpoint for HRMS PostgreSQL RDS instance"
}

output "backend_ecr_repository_url" {
  value       = aws_ecr_repository.backend.repository_url
  description = "URL of the backend Docker image ECR repository"
}

output "frontend_ecr_repository_url" {
  value       = aws_ecr_repository.frontend.repository_url
  description = "URL of the frontend Docker image ECR repository"
}