# Configure the AWS Provider
provider "aws" {
  region = "us-east-2"
}
 
# Create a VPC
resource "aws_vpc" "uturn" {
  cidr_block = "10.0.0.0/16"
}
 
# Create public subnets
resource "aws_subnet" "pubsn1" {
  vpc_id            = aws_vpc.uturn.id
  cidr_block        = "10.0.10.0/24"
  availability_zone = "us-east-2a"
 
  tags = {
    Name = "pubsn1"
  }
}
 
resource "aws_subnet" "pubsn2" {
  vpc_id            = aws_vpc.uturn.id
  cidr_block        = "10.0.20.0/24"
  availability_zone = "us-east-2b"
 
  tags = {
    Name = "pubsn2"
  }
}
 
# Create internet gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.uturn.id
 
  tags = {
    Name = "igw"
  }
}
 
# Create route table 
resource "aws_route_table" "rtab" {
  vpc_id = aws_vpc.uturn.id
 
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
 
  #route {
  #ipv6_cidr_block        = "::/0"
  #egress_only_gateway_id = aws_egress_only_internet_gateway.example.id
  #}
 
  tags = {
    Name = "rtab"
  }
}
 
# Associate route table to public subnet 1
resource "aws_route_table_association" "rtab_sn1" {
  subnet_id      = aws_subnet.pubsn1.id
  route_table_id = aws_route_table.rtab.id
}
 
# Associate route table to public subnet 2
resource "aws_route_table_association" "rtab_sn2" {
  subnet_id      = aws_subnet.pubsn2.id
  route_table_id = aws_route_table.rtab.id
}
 
#create security group 
resource "aws_security_group" "sg" {
  name        = "sg"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.uturn.id
 
  ingress {
    description = "TLS from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    #ipv6_cidr_blocks = [aws_vpc.main.ipv6_cidr_block]
  }
 
  ingress {
    description = "ssh"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    #ipv6_cidr_blocks = [aws_vpc.main.ipv6_cidr_block]
  }
 
  ingress {
    description = "app-port"
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    #ipv6_cidr_blocks = [aws_vpc.main.ipv6_cidr_block]
  }
 
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
 
  tags = {
    Name = "sg"
  }
}
 
# Create instance in public subnet 1
resource "aws_instance" "instance1" {
  ami               = "ami-0283a57753b18025b"
  instance_type     = "t2.micro"
  iam_instance_profile = aws_iam_instance_profile.profile.name
  subnet_id         = aws_subnet.pubsn1.id
  availability_zone = "us-east-2a"
  associate_public_ip_address = true
  #key_name = ""
  security_groups = [aws_security_group.sg.id]
  tags = {
    "Name" = "ubuntu-1"
  }
 
# create bash script 
  user_data = <<-EOF
  #!/bin/bash
  sudo apt update -y
  sudo apt upgrade -y
  cd /home/ubuntu/
  sudo mkdir flask
  cd flask
  git init
  git clone https://github.com/Ucheudeze/2022-Challenge-.git
  cd 2022-Challenge-/
  export TC_DYNAMO_TABLE=ddb
  sudo add-apt-repository universe
  sudo apt update
  sudo apt install python3-pip -y
  sudo pip install -r requirements.txt 
  sudo apt install gunicorn -y
  sudo gunicorn -b 0.0.0.0 app:candidates_app &

  touch /etc/systemd/system/flask.service

  echo "[Unit]" >> /etc/systemd/system/flask.service
  echo "Description=flask_service" >> /etc/systemd/system/flask.service

  echo "[Service]" >> /etc/systemd/system/flask.service
  echo "ExecStart=/bin/bash -c 'cd /home/ubuntu/flask/2022-Challenge-/ &&  gunicorn -b 0.0.0.0 app:candidates_app'" >> /etc/systemd/system/flask.service
  echo "ExecStartPost=/bin/bash -c 'cd /home/ubuntu/flask/2022-Challenge-/ && python3 test_candidates.py'" >> /etc/systemd/system/flask.service
  echo "ExecStop=" >> /etc/systemd/system/flask.service
  echo "Type=forking" >> /etc/systemd/system/flask.service
  echo "TimeoutStartSec=300" >> /etc/systemd/system/flask.service
  echo "TimeoutStopSec=300" >> /etc/systemd/system/flask.service

  echo "[Install]" >> /etc/systemd/system/flask.service
  echo "WantedBy=multi-user.target" >> /etc/systemd/system/flask.service

  sudo systemctl enable flask.service

  EOF
}
 
# Create instance in public subnet 2
resource "aws_instance" "instance2" {
  ami               = "ami-0283a57753b18025b"
  instance_type     = "t2.micro"
  iam_instance_profile = aws_iam_instance_profile.profile.name
  subnet_id         = aws_subnet.pubsn2.id
  availability_zone = "us-east-2b"
  associate_public_ip_address = true
  #key_name = ""
  security_groups = [aws_security_group.sg.id]
  tags = {
    "Name" = "ubuntu-2"
  }
 
# create bash script 
  user_data = <<-EOF
  #!/bin/bash
  sudo apt update -y
  sudo apt upgrade -y
  cd /home/ubuntu/
  sudo mkdir flask
  cd flask
  git init
  git clone https://github.com/Ucheudeze/2022-Challenge-.git
  cd 2022-Challenge-/
  export TC_DYNAMO_TABLE=ddb
  sudo add-apt-repository universe
  sudo apt update
  sudo apt install python3-pip -y
  sudo pip install -r requirements.txt 
  sudo apt install gunicorn -y
  sudo gunicorn -b 0.0.0.0 app:candidates_app &

  touch /etc/systemd/system/flask.service

  echo "[Unit]" >> /etc/systemd/system/flask.service
  echo "Description=flask_service" >> /etc/systemd/system/flask.service

  echo "[Service]" >> /etc/systemd/system/flask.service
  echo "ExecStart=/bin/bash -c 'cd /home/ubuntu/flask/2022-Challenge-/ &&  gunicorn -b 0.0.0.0 app:candidates_app'" >> /etc/systemd/system/flask.service
  echo "ExecStartPost=/bin/bash -c 'cd /home/ubuntu/flask/2022-Challenge-/ && python3 test_candidates.py'" >> /etc/systemd/system/flask.service
  echo "ExecStop=" >> /etc/systemd/system/flask.service
  echo "Type=forking" >> /etc/systemd/system/flask.service
  echo "TimeoutStartSec=300" >> /etc/systemd/system/flask.service
  echo "TimeoutStopSec=300" >> /etc/systemd/system/flask.service

  echo "[Install]" >> /etc/systemd/system/flask.service
  echo "WantedBy=multi-user.target" >> /etc/systemd/system/flask.service

  sudo systemctl enable flask.service

  EOF
}
 
# Create Load balancer
resource "aws_lb" "nlb" {
  name               = "nlb"
  internal           = false
  load_balancer_type = "network"
  subnets            = [aws_subnet.pubsn1.id, aws_subnet.pubsn2.id]
 
  #enable_deletion_protection = true
 
  tags = {
    Environment = "production"
  }
}
# Create target group
 
resource "aws_lb_target_group" "tg" {
  name        = "alb"
  target_type = "instance"
  port        = 8000
  protocol    = "TCP"
  vpc_id      = aws_vpc.uturn.id
 
  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    path                = "/gtg"
    port                = 8000
    protocol            = "HTTP"
    interval            = 30
  }
}

resource "aws_lb_target_group_attachment" "tg_attachment_1" {
    target_group_arn = aws_lb_target_group.tg.arn
    target_id        = aws_instance.instance1.id
    port             = 8000
}

resource "aws_lb_target_group_attachment" "tg_attachment_2" {
    target_group_arn = aws_lb_target_group.tg.arn
    target_id        = aws_instance.instance2.id
    port             = 8000
}

 
# Create listener
resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.nlb.arn
  port              = 80
  protocol          = "TCP"
 
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}
 
 
resource "aws_dynamodb_table" "candidate-table" {
  name           = "Candidates"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "CandidateName"

  attribute {
    name = "CandidateName"
    type = "S"
  }

  ttl {
    attribute_name = "TimeToExist"
    enabled        = false
  }
  
  lifecycle {
    ignore_changes = [
      ttl
    ]
  }
}

resource "aws_iam_policy" "dynamodb-policy" {
  name        = "dynamodb-Access-Policy"
  description = "Provides permission to access dynamodb"

  policy = jsonencode(
    {
        "Version": "2012-10-17",
        "Statement": [
            {
                "Sid": "DescribeQueryScanBooksTable",
                "Effect": "Allow",
                "Action": [
                    "dynamodb:*"
                ],
                "Resource": "arn:aws:dynamodb:us-east-2:*:table/*"
            }
        ]
    }
  )
}

resource "aws_iam_role" "role" {
  name = "ec2_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = "RoleForEC2"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_policy_attachment" "attach" {
  name       = "attachment"
  roles      = [aws_iam_role.role.name]
  policy_arn = aws_iam_policy.dynamodb-policy.arn
}

resource "aws_iam_instance_profile" "profile" {
  name = "profile"
  role = aws_iam_role.role.name
}


