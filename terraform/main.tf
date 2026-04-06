terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.39.0"
    }
  }
}

provider "aws" {
  region = "ap-south-1"
}

#----VPC----

resource "aws_vpc" "myvpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "jenkins-vpc"
  }
}

#----SUBNET----

resource "aws_subnet" "subnet1" {
  vpc_id                  = aws_vpc.myvpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  tags = {
    Name = "jenkins-subnet"
  }
}

#----INTERNET GATEWAY----

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.myvpc.id
}

#----ROUTE TABLE----

resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.myvpc.id
}

resource "aws_route" "r" {
  route_table_id         = aws_route_table.rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.gw.id
}

resource "aws_route_table_association" "rta" {
  subnet_id      = aws_subnet.subnet1.id
  route_table_id = aws_route_table.rt.id
}

#----SECURITY GROUP----

resource "aws_security_group" "SG" {
  name        = "allow-tls"
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.myvpc.id

  tags = {
    Name = "jk-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "ipv4-http" {
  security_group_id = aws_security_group.SG.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_ingress_rule" "ipv4-ssh" {
  security_group_id = aws_security_group.SG.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_ingress_rule" "jk" {
  security_group_id = aws_security_group.SG.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 8080
  ip_protocol       = "tcp"
  to_port           = 8080
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.SG.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

#----IAM ROLE----

resource "aws_iam_role" "jenkins_role" {
  name = "test_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eks_policy" {
  role       = aws_iam_role.jenkins_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_role_policy_attachment" "eks_worker" {
  role       = aws_iam_role.jenkins_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_instance_profile" "jenkins_profile" {
  name = "jenkins-profile"
  role = aws_iam_role.jenkins_role.name
}

#----EC2 INSTANCE----

resource "aws_instance" "jenkins" {
  ami                    = "ami-045443a70fafb8bbc" # Amazon Linux
  instance_type          = "t3.medium"
  subnet_id              = aws_subnet.subnet1.id
  vpc_security_group_ids = [aws_security_group.SG.id]

  iam_instance_profile = aws_iam_instance_profile.jenkins_profile.name

  key_name = "keyfile"

  user_data = <<-EOF
              #!/bin/bash
              yum update -y

              # Install Docker
              yum install -y docker
              systemctl start docker
              systemctl enable docker

              # Install Java
              yum install -y java-17-amazon-corretto

              # Install Jenkins
              wget -O /etc/yum.repos.d/jenkins.repo \
              https://pkg.jenkins.io/redhat-stable/jenkins.repo
              rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
              yum install -y jenkins
              systemctl start jenkins
              systemctl enable jenkins

              # Install AWS CLI
              yum install -y aws-cli

              # Install kubectl
              curl -LO "https://dl.k8s.io/release/$(curl -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
              chmod +x kubectl
              mv kubectl /usr/local/bin/
              EOF

  tags = {
    Name = "Jenkins-Server"
  }
}
