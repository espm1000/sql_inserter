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

variable "es_namespace" {
  type = string
}

variable "es_stage" {
  type = string
}

variable "es_dns_zone_id" {
  type = string
}

variable "es_version" {
  type = string
}

variable "es_instance_type" {
  type = string
}

variable "es_ebs_vol_size" {
  type = string
}

variable "kibana_subdomain_name" {
  type = string
}

variable "es_count" {
  type = number
}
