variable "ssh_key_name" {
  description = "The name of the SSH key pair to use for instances"
  type        = string
  default     = "hsms-stg-common"
}

variable "create_infra" {
  description = "When true, Terraform will create VPC, subnets, IAM roles and related infra. When false, existing resource IDs/ARNs must be provided."
  type        = bool
  default     = true
}

variable "existing_vpc_id" {
  description = "Existing VPC ID to use when create_infra=false"
  type        = string
  default     = ""
}

variable "existing_subnet_ids" {
  description = "List of existing subnet IDs to use when create_infra=false"
  type        = list(string)
  default     = []
}

variable "existing_cluster_role_arn" {
  description = "Existing IAM role ARN for EKS cluster when create_infra=false"
  type        = string
  default     = ""
}

variable "existing_node_role_arn" {
  description = "Existing IAM role ARN for EKS node group when create_infra=false"
  type        = string
  default     = ""
}

variable "existing_cluster_security_group_ids" {
  description = "Existing security group IDs for the EKS cluster when create_infra=false"
  type        = list(string)
  default     = []
}

variable "existing_node_security_group_ids" {
  description = "Existing security group IDs for the EKS nodes when create_infra=false"
  type        = list(string)
  default     = []
}

variable "aws_region" {
  description = "AWS region to operate in"
  type        = string
  default     = "us-east-1"
}
