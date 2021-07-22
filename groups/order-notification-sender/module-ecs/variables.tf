# Metadata
variable "deployment_name" {
  description = "The name of the deployment."
  type = string
}

variable "environment" {
  description = "The name of the environment."
  type = string
}

variable "application_name" {
  description = "The name of the application."
  type = string
}

# Network configuration
variable "vpc_id" {
  description = "The ID of the VPC that the security group will be part of."
  type = string
}

variable "subnets" {
  description = "The subnets that will be allocated to the application."
  type = list(string)
}

# IAM configuration
variable "role_arn" {
  description = "The ARN of the execution role that will be allocated to the ECS task."
  type = string
}

# Container configuration
variable "container_insights_enabled" {
  description = "Toggle container insights to monitor resource usage and performance."
  type = bool
}

variable "cpu_units" {
  description = "The number of CPU units that will be allocated to the ECS task definition."
  type = number
}

variable "memory" {
  description = "The amount of memory required by the ECS task definition"
  type = number
}

variable "task_definition_parameters" {
  description = "Environment variables and container properties for ECS task definition"
  type = map(any)
}