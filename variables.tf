# Borrowed from VPC Module from Terraform Module Repository:
variable "region" {
    description = "AWS Region"
}

variable "env" {
    description = "Application environment"
}

variable "domain_name" {
    description = "Domain name for the applications"
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC. Default value is a valid CIDR, but not acceptable by AWS and should be overriden"
  default     = "10.0.0.0/16"
}

variable "vpc_public_subnets" {
  description = "A list of public subnets inside the VPC"
  default     = []
}

variable "vpc_private_subnets" {
  description = "A list of private subnets inside the VPC"
  default     = []
}

variable "vpc_azs" {
  description = "A list of availability zones in the region"
  default     = []
}

variable "vpc_enable_nat_gateway" {
  description = "Should be true if you want to provision NAT Gateways for each of your private networks"
  default     = false
}

variable "vpc_single_nat_gateway" {
  description = "Should be true if you want to provision a single shared NAT Gateway across all of your private networks"
  default     = false
}

variable "vpc_one_nat_gateway_per_az" {
  description = "Should be true if you want only one NAT Gateway per availability zone. Requires `var.azs` to be set, and the number of `public_subnets` created to be greater than or equal to the number of availability zones specified in `var.azs`."
  default     = false
}

#######################

variable "ssm_db_password" {}

variable "db_allocated_storage" {
  description = "The allocated storage in GB"
  default = 5
}

variable "db_name" {
  description = "The DB name to create"
  default = ""
}

variable "db_username" {
  description = "Username for the master DB user"
  default = ""
}

variable "db_password" {
  description = "Password for the master DB user"
  default = ""
}

variable "db_port" {
  description = "The port on which the DB accepts connections"
  default = 5432
}

variable "db_maintenance_window" {
  description = "The window to perform maintenance in"
  default = "Mon:00:00-Mon:03:00"
}

variable "db_backup_window" {
  description = "The daily time range (in UTC) during which automated backups are created if they are enabled"
  default = "03:00-06:00"
}

variable "db_backup_retention_period" {
  description = "The days to retain backups for"
  default = 0
}


########

variable proxy_version{
  default = null
}

variable proxy_ami_name {
  default = "amzn-ami-hvm-*-x86_64-gp2"
}

variable app_version{
  default = null
}

variable app_ami_name {
  default = "amzn-ami-hvm-*-x86_64-gp2"
}

variable proxy_app_port {}

variable app_port {}