data "aws_availability_zones" "available" {}

locals {
  vpc_cidr         = "10.0.0.0/16"
  azs              = slice(data.aws_availability_zones.available.names, 0, 3)
  vpc_name         = "application_vpc"
  client_public_ip = "63.231.146.30/32"
  all_ip           = "0.0.0.0/0"
  tags = {
    Name        = "debian"
    environment = "application"
  }
}

#####
## VPC CONFIG
#####

module "vpc" {
  source                                 = "terraform-aws-modules/vpc/aws"
  name                                   = local.vpc_name
  create_database_subnet_group           = true
  create_database_internet_gateway_route = true
  create_igw                             = true
  azs                                    = local.azs

  private_subnets  = [for key, value in local.azs : cidrsubnet(local.vpc_cidr, 4, key)]
  public_subnets   = [for key, value in local.azs : cidrsubnet(local.vpc_cidr, 4, key + 4)]
  database_subnets = [for key, value in local.azs : cidrsubnet(local.vpc_cidr, 4, key + 8)]

  tags = {
    Name = local.vpc_name
  }
}

#####
## SECURITY GROUPS & IAM
#####

resource "aws_key_pair" "ec2" {
  key_name   = "temp_key"
  public_key = file("resources/temp_key.pub")
}

resource "aws_security_group" "postgres_public" {
  name        = "allow_pgsql"
  description = "Allow communication to Postgres on 5432"
  vpc_id      = module.vpc.vpc_id

  tags = {
    Name = "Allow PGSQL"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_pgsql_in" {
  security_group_id = aws_security_group.postgres_public.id
  cidr_ipv4         = "${module.ec2[0].private_ip}/32"
  from_port         = 5432
  ip_protocol       = "TCP"
  to_port           = 5432
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh_in" {
  security_group_id = aws_security_group.postgres_public.id
  cidr_ipv4         = local.client_public_ip
  from_port         = 22
  ip_protocol       = "TCP"
  to_port           = 22
}

resource "aws_vpc_security_group_egress_rule" "allow_all" {
  security_group_id = aws_security_group.postgres_public.id
  cidr_ipv4         = local.client_public_ip
  ip_protocol       = "-1"
}

#####
## EC2 CONFIG
#####

data "aws_ami" "debian" {
  most_recent = true

  filter {
    name   = "name"
    values = ["debian-12-amd64-*-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["136693071363"]

}

module "ec2" {
  count                       = 1
  depends_on                  = [module.vpc]
  ami                         = data.aws_ami.debian.id
  instance_type               = "t2.micro"
  source                      = "terraform-aws-modules/ec2-instance/aws"
  name                        = "debian"
  vpc_security_group_ids      = [aws_security_group.postgres_public.id]
  subnet_id                   = module.vpc.public_subnets[0]
  associate_public_ip_address = true
  key_name                    = aws_key_pair.ec2.key_name

  tags = local.tags

}

output "ipv4_address" {
  value = module.ec2[*].public_ip
}

#####
## RDS CONFIG
#####

resource "aws_db_instance" "postgres" {
  count                  = 1 # On/Off Switch
  identifier             = "guest-book-database"
  allocated_storage      = 10
  db_name                = "guest_book"
  engine                 = "postgres"
  engine_version         = "15"
  instance_class         = "db.t3.micro"
  username               = "appuser"
  password               = "Appuser7818!"
  skip_final_snapshot    = true
  vpc_security_group_ids = [aws_security_group.postgres_public.id]
  publicly_accessible    = true

  db_subnet_group_name = module.vpc.database_subnet_group_name
}

output "http_endpoint" {
  value = aws_db_instance.postgres[0].endpoint
}
