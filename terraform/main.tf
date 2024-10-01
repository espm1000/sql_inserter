data "aws_availability_zones" "available" {}

locals {
  vpc_cidr         = "10.0.0.0/16"
  azs              = slice(data.aws_availability_zones.available.names, 0, 2)
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
  count                                  = var.vpc_count
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
  count      = var.key_pair_count
  key_name   = "temp_key"
  public_key = file("resources/temp_key.pub")
}

resource "aws_security_group" "postgres_public" {
  count       = var.security_group_postgres_ingress_count
  name        = "allow_pgsql"
  description = "Allow communication to Postgres on 5432"
  vpc_id      = count.index >= 1 ? module.vpc.vpc_id : null

  tags = {
    Name = "Allow PGSQL"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_pgsql_in" {
  count             = var.security_group_postgres_ingress_count
  security_group_id = aws_security_group.postgres_public[count.index].id
  cidr_ipv4         = "${module.ec2[0].private_ip}/32"
  from_port         = 5432
  ip_protocol       = "TCP"
  to_port           = 5432
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh_in" {
  count             = var.security_group_ssh_ingress_count
  security_group_id = aws_security_group.postgres_public[count.index].id
  cidr_ipv4         = local.client_public_ip
  from_port         = 22
  ip_protocol       = "TCP"
  to_port           = 22
}

resource "aws_vpc_security_group_egress_rule" "allow_all" {
  count             = var.security_group_ssh_ingress_count
  security_group_id = aws_security_group.postgres_public[count.index].id
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
  count                       = var.ec2_count
  depends_on                  = [module.vpc]
  ami                         = data.aws_ami.debian.id
  instance_type               = "t2.micro"
  source                      = "terraform-aws-modules/ec2-instance/aws"
  name                        = "debian"
  vpc_security_group_ids      = [count.index >= 1 ? aws_security_group.postgres_public[count.index].id : null]
  subnet_id                   = count.index >= 1 ? module.vpc.public_subnets[0] : null
  associate_public_ip_address = true
  key_name                    = count.index >= 1 ? aws_key_pair.ec2[count.index].key_name : null

  tags = local.tags

}

output "ipv4_address" {
  value = module.ec2[*].public_ip
}

#####
## RDS CONFIG
#####

resource "aws_db_instance" "postgres" {
  count                  = var.rds_count
  identifier             = "guest-book-database"
  allocated_storage      = 10
  db_name                = "guest_book"
  engine                 = "postgres"
  engine_version         = "15"
  instance_class         = "db.t3.micro"
  username               = "appuser"
  password               = "Appuser7818!"
  skip_final_snapshot    = true
  vpc_security_group_ids = [count.index >= 1 ? aws_security_group.postgres_public[count.index].id : null]
  publicly_accessible    = true

  db_subnet_group_name = module.vpc[count.index].database_subnet_group_name
}

//output "http_endpoint" {
//  value = aws_db_instance.postgres[0].endpoint
//}

#####
## SQS
#####

data "aws_iam_policy_document" "lambda_sqs" {
  statement {
    actions   = ["sqs:*"]
    effect    = "Allow"
    resources = ["*"]
  }
}

resource "aws_iam_policy" "lambda_sqs_policy" {
  name   = "lambda_sqs_policy"
  path   = "/"
  policy = data.aws_iam_policy_document.lambda_sqs.json
}

resource "aws_sqs_queue" "messages" {
  count = var.sqs_count
  name  = "messages_queue-${count.index}"

  tags = {
    Name = "messages_queue-${count.index}"
  }
}

module "sqs_lambda" {
  count         = var.lambda_count
  source        = "terraform-aws-modules/lambda/aws"
  function_name = "sqs_lambda-${count.index}"
  description   = "Sends message to SQS queue"
  handler       = var.lambda_handler
  runtime       = "python3.12"
  attach_policy = true
  policy        = aws_iam_policy.lambda_sqs_policy.arn
  source_path   = var.function_source_path

  create_current_version_allowed_triggers = false
  allowed_triggers = {
    AllowInvokeFromCloudWatch = {
      principal  = "events.amazonaws.com"
      source_arn = module.lambda_eventbridge[0].eventbridge_rule_arns["crons"]
    }
  }

  environment_variables = {
    QUEUE_NAME    = var.sqs_count >= 1 ? aws_sqs_queue.messages[count.index].name : null
    QUEUE_MESSAGE = "insert message here"
    TOPIC_ARN     = var.sns_topic_count >= 1 ? aws_sns_topic.send_data[0].arn : ""
  }

  tags = {
    Name = "sqs-lambda"
  }
}

#####
## SNS
#####

resource "aws_sns_topic" "send_data" {
  count = var.sns_topic_count
  name  = "send_data_to_queues"
}

#####
## EVENTBRIDGE
#####

module "lambda_eventbridge" {
  count  = var.eventbridge_count
  source = "terraform-aws-modules/eventbridge/aws"

  create_bus           = false
  create_role          = true
  attach_lambda_policy = true
  lambda_target_arns   = [module.sqs_lambda[0].lambda_function_arn]

  rules = {
    crons = {
      description         = "Every X Minutes"
      schedule_expression = "rate(2 minutes)"
    }
  }

  targets = {
    crons = [
      {
        name  = module.sqs_lambda[0].lambda_function_name
        arn   = module.sqs_lambda[0].lambda_function_arn
        input = jsonencode({ "job" : "cron-by-rate" })

      }

    ]
  }
}

output "events" {
  value = module.lambda_eventbridge[0].eventbridge_rule_arns
}