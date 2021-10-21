provider "aws" {
  region = var.aws_region
  version = "~> 3.26.0" # first provider version where SSO is supported
}

provider "vault" {
  auth_login {
    path = "auth/userpass/login/${var.vault_username}"
    parameters = {
      password = var.vault_password
    }
  }
}

terraform {
  backend "s3" {}
}

data "terraform_remote_state" "networks" {
  backend = "s3"
  config = {
    bucket = var.remote_state_bucket
    key = "${var.state_prefix}/${var.deploy_to}/${var.deploy_to}.tfstate"
    region = var.aws_region
  }
}

data "terraform_remote_state" "services-stack-configs" {
  backend = "s3"
  config = {
    bucket = var.aws_bucket
    # aws-common-infrastructure-terraform repo uses the same remote state bucket
    key = "aws-common-infrastructure-terraform/common-${var.aws_region}/services-stack-configs.tfstate"
    region = var.aws_region
  }
}

locals {
  stack_name = "order-notification-sender"
  stack_fullname = "${local.stack_name}-stack"
  name_prefix = "${local.stack_name}-${var.environment}"
}

data "vault_generic_secret" "secrets" {
  path = "applications/${var.aws_profile}/${var.environment}/${local.stack_fullname}"
}

module "order-notification-secrets" {
  source = "./module-secrets"
  stack_name = local.stack_name
  name_prefix = local.name_prefix
  environment = var.environment
  kms_key_id = data.terraform_remote_state.services-stack-configs.outputs.services_stack_configs_kms_key_id
  secrets = data.vault_generic_secret.secrets.data
}

module "order-notification-iam" {
  source = "./module-iam"
  deployment_name = local.name_prefix
}

module "order-notification-ecs" {
  source = "./module-ecs"
  application_name = local.stack_name
  environment = var.environment
  cpu_units = var.cpu_units
  memory = var.memory
  deployment_name = local.name_prefix
  role_arn = module.order-notification-iam.task_execution_arn
  vpc_id = data.terraform_remote_state.networks.outputs.vpc_id
  subnets = split(",", data.terraform_remote_state.networks.outputs.application_ids)
  container_insights_enabled = var.container_insights_enabled
  task_definition_parameters = merge({
    aws_region = var.aws_region
    service_name = local.stack_name
    name_prefix = local.name_prefix
    docker_registry = var.docker_registry
    release_version = var.release_version
    java_mem_args = var.java_mem_args
    kafka_producer_timeout = var.kafka_producer_timeout
    maximum_retries = var.maximum_retries
    dynamic_llp_certificate_orders_enabled = var.dynamic_llp_certificate_orders_enabled
    dynamic_lp_certificate_orders_enabled = var.dynamic_lp_certificate_orders_enabled
  }, module.order-notification-secrets.secrets_arn_map)
}
