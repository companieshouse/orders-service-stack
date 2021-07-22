# AWS
variable "aws_region" {
  description = "The AWS region for deployment."
  type = string
  default = "eu-west-2"
}

variable "aws_profile" {
  description = "The AWS profile to use for deployment."
  type = string
}

variable "aws_bucket" {
  description = "The bucket used to store the current terraform state files."
  type = string
}

variable "remote_state_bucket" {
  description = "Alternative bucket used to store the remote state files from ch-service-terraform"
  type = string
}

# Deployment
variable "environment" {
  description = "The environment this stack will be created for."
  type = string
}

variable "deploy_to" {
  description = "Bucket namespace used with remote_state_bucket and state_prefix."
  type = string
}

variable "state_prefix" {
  description = "The bucket prefix used with the remote_state_bucket files."
  type = string
}

variable "docker_registry" {
  description = "The FQDN of the Docker registry."
  type = string
}

variable "release_version" {
  description = "The version of data-reconciliation that will be deployed."
  type = string
}

variable "container_insights_enabled" {
  description = "Toggle container insights to monitor resource usage and performance."
  type = bool
  default = false
}

# Secrets
variable "vault_username" {
  description = "The username used by the Vault provider."
  type = string
}

variable "vault_password" {
  description = "The password used by the Vault provider."
  type = string
}

# Container configuration
variable "cpu_units" {
  description = "The number of AWS CPU units (as defined as by the ECS docs)"
  type = number
}

variable "memory" {
  description = "The memory in megabytes"
  type = number
}

# Application environment variables
variable "java_mem_args" {
  description = "The memory designated for controlling the heap size to control the RAM usage in java applications."
  type = string
  default = ""
}