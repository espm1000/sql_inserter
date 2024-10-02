variable "sqs_count" {
  type = number
}

variable "lambda_count" {
  type = number
}

variable "rds_count" {
  type = number
}

variable "vpc_count" {
  type = number
}

variable "security_group_ssh_ingress_count" {
  type = number
}

variable "ec2_count" {
  type = number
}

variable "key_pair_count" {
  type = number
}

variable "security_group_postgres_ingress_count" {
  type = number

}

variable "sns_topic_count" {
  type = number
}

variable "function_source_path" {
  type = string
}

variable "eventbridge_count" {
  type = number
}

variable "lambda_handler" {
  type = string
}

variable "eventbridge_schedule_expression" {
  type = string
}

variable "generic_security_group_count" {
  type = string
}
