variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "ap-south-1"
}

variable "project_name" {
  description = "Project name used for tagging resources"
  type        = string
  default     = "hr-management-system"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "key_pair_name" {
  description = "Existing EC2 key pair name for SSH access to Jenkins server"
  type        = string
}

variable "db_password" {
  description = "Master password for RDS PostgreSQL instance"
  type        = string
  sensitive   = true
}