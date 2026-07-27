variable "availability_zone_1" {
  description = "The availability zone for the first subnet"
  default     = "us-east-1a"
  type        = string
}

variable "availability_zone_2" {
  description = "The availability zone for the second subnet"
  default     = "us-east-1b"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "private_subnet_1_az_cidr" { type = string }
variable "private_subnet_2_az_cidr" { type = string }
variable "private_subnet_1_rds_cidr" { type = string }
variable "private_subnet_2_rds_cidr" { type = string }
variable "public_subnet_1_cidr" { type = string }
variable "public_subnet_2_cidr" { type = string }