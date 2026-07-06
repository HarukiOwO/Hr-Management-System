module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "${var.project_name}-vpc"
  cidr = var.vpc_cidr

  azs = ["${var.aws_region}a", "${var.aws_region}b", "${var.aws_region}c"]

  # Public subnets — for ALB
  public_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]

  # Private subnets — for EKS worker nodes
  private_subnets = ["10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24"]

  # Isolated DB subnets — for RDS, no internet route at all
  database_subnets = ["10.0.21.0/24", "10.0.22.0/24", "10.0.23.0/24"]

  # --- Cost-saving setting for now ---
  enable_nat_gateway = true
  single_nat_gateway = true # 1 NAT shared across all AZs (cheap, testing phase)
  # For production later, replace above two lines with:
  # single_nat_gateway     = false
  # one_nat_gateway_per_az = true

  create_database_subnet_group = true
  enable_dns_hostnames         = true
  enable_dns_support           = true

  # Required tags for EKS to auto-discover subnets later
  public_subnet_tags = {
    "kubernetes.io/role/elb" = "1"
  }
  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = "1"
  }

  tags = {
    Project = var.project_name
  }
}