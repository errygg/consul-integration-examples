terraform {
  required_version = "~> 0.12"
}

provider "aws" {
  region = var.region
}

resource "aws_vpc" "consul_eks" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = var.namespace
  }
}

resource "aws_subnet" "consul_eks" {
  vpc_id            = aws_vpc.consul_eks.id
  cidr_block        = cidrsubnet(aws_vpc.consul_eks.cidr_block, 3, 1)
  availability_zone = join("", [var.region, "a"])
  tags = {
    Name = var.namespace
  }
}

resource "aws_internet_gateway" "consul_eks" {
  vpc_id = aws_vpc.consul_eks.id
  tags = {
    Name = var.namespace
  }
}

resource "aws_route_table" "consul_eks" {
  vpc_id = aws_vpc.consul_eks.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.consul_eks.id
  }
}

resource "aws_route_table_association" "consul_eks" {
  subnet_id      = aws_subnet.consul_eks.id
  route_table_id = aws_route_table.consul_eks.id
}

resource "aws_iam_role" "consul_eks" {
  name = "terraform-consul-eks"

  assume_role_policy = <<POLICY
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
POLICY
}

resource "aws_iam_role_policy_attachment" "consul_eks_AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.consul_eks.name
}

resource "aws_iam_role_policy_attachment" "consul_eks_AmazonEKSServicePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.eks-example.name
}

resource "aws_eks_cluster" "consul_eks" {
  role_arn = aws_iam_role.consul_eks.arn
  vpc_config {
    subnet_ids = [aws_subnet.consul_eks.id]
  }
  depends_on = 
}

resource "aws_security_group" "consul_eks" {
  vpc_id = aws_vpc.consul_eks.id

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = var.namespace
  }
}

resource "aws_security_group_rule" "