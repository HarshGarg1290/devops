terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 5.0.0"
    }
  }
  # OPTIONAL: configure a remote backend to manage state for teams. Example S3 backend:
  # backend "s3" {
  #   bucket = "<your-terraform-state-bucket>"
  #   key    = "devops-projects/eks/terraform.tfstate"
  #   region = "ap-southeast-1"
  # }
}

provider "aws" {
  region = var.aws_region
}

locals {
  vpc_id = var.create_infra ? aws_vpc.abrahimcse_vpc[0].id : var.existing_vpc_id
  subnet_ids = var.create_infra ? aws_subnet.abrahimcse_subnet[*].id : var.existing_subnet_ids
  cluster_role_arn = var.create_infra ? aws_iam_role.abrahimcse_cluster_role[0].arn : var.existing_cluster_role_arn
  node_role_arn = var.create_infra ? aws_iam_role.abrahimcse_node_group_role[0].arn : var.existing_node_role_arn
  cluster_security_group_ids = var.create_infra ? [aws_security_group.abrahimcse_cluster_sg[0].id] : var.existing_cluster_security_group_ids
  node_security_group_ids = var.create_infra ? [aws_security_group.abrahimcse_node_sg[0].id] : var.existing_node_security_group_ids
}

resource "aws_vpc" "abrahimcse_vpc" {
  count      = var.create_infra ? 1 : 0
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "abrahimcse-vpc"
  }
}

resource "aws_subnet" "abrahimcse_subnet" {
  count = var.create_infra ? 2 : 0
  vpc_id = aws_vpc.abrahimcse_vpc[0].id
  cidr_block              = cidrsubnet(aws_vpc.abrahimcse_vpc[0].cidr_block, 8, count.index)
  availability_zone       = element(["ap-southeast-1a", "ap-southeast-1b"], count.index)
  map_public_ip_on_launch = true

  tags = {
    Name = "abrahimcse-subnet-${count.index}"
  }
}

resource "aws_internet_gateway" "abrahimcse_igw" {
  count = var.create_infra ? 1 : 0
  vpc_id = aws_vpc.abrahimcse_vpc[0].id

  tags = {
    Name = "abrahimcse-igw"
  }
}

resource "aws_route_table" "abrahimcse_route_table" {
  count = var.create_infra ? 1 : 0
  vpc_id = aws_vpc.abrahimcse_vpc[0].id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.abrahimcse_igw[0].id
  }

  tags = {
    Name = "abrahimcse-route-table"
  }
}

resource "aws_route_table_association" "a" {
  count = var.create_infra ? 2 : 0
  subnet_id      = aws_subnet.abrahimcse_subnet[count.index].id
  route_table_id = aws_route_table.abrahimcse_route_table[0].id
}

resource "aws_security_group" "abrahimcse_cluster_sg" {
  count = var.create_infra ? 1 : 0
  vpc_id = aws_vpc.abrahimcse_vpc[0].id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "abrahimcse-cluster-sg"
  }
}

resource "aws_security_group" "abrahimcse_node_sg" {
  count = var.create_infra ? 1 : 0
  vpc_id = aws_vpc.abrahimcse_vpc[0].id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "abrahimcse-node-sg"
  }
}

resource "aws_eks_cluster" "abrahimcse" {
  name     = "abrahimcse-cluster"
  role_arn = local.cluster_role_arn

  vpc_config {
    subnet_ids         = local.subnet_ids
    security_group_ids = local.cluster_security_group_ids
  }
}

resource "aws_eks_node_group" "abrahimcse" {
  cluster_name    = aws_eks_cluster.abrahimcse.name
  node_group_name = "abrahimcse-node-group"
  node_role_arn   = local.node_role_arn
  subnet_ids      = local.subnet_ids

  scaling_config {
    desired_size = 3
    max_size     = 3
    min_size     = 3
  }

  instance_types = ["t2.large"]

  remote_access {
    ec2_ssh_key = var.ssh_key_name
    source_security_group_ids = local.node_security_group_ids
  }
}

resource "aws_iam_role" "abrahimcse_cluster_role" {
  count = var.create_infra ? 1 : 0
  name = "abrahimcse-cluster-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "abrahimcse_cluster_role_policy" {
  count = var.create_infra ? 1 : 0
  role       = aws_iam_role.abrahimcse_cluster_role[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_role" "abrahimcse_node_group_role" {
  count = var.create_infra ? 1 : 0
  name = "abrahimcse-node-group-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "abrahimcse_node_group_role_policy" {
  count = var.create_infra ? 1 : 0
  role       = aws_iam_role.abrahimcse_node_group_role[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "abrahimcse_node_group_cni_policy" {
  count = var.create_infra ? 1 : 0
  role       = aws_iam_role.abrahimcse_node_group_role[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "abrahimcse_node_group_registry_policy" {
  count = var.create_infra ? 1 : 0
  role       = aws_iam_role.abrahimcse_node_group_role[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}
