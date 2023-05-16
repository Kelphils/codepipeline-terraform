# run the command below to specify the path for configuration of the
# terraform state in S3 bucket with the DynamoDb table as the backend and encryption, locking enabled
# terraform init -backend-config=backend.hcl
locals {
  # Dynamic repo list
  deployment = {
    Repo-1 = {
      repo = "Kelphils/codepipeline-terraform"
    }
    # Repo-2 = {
    #   repo = "GitHub-Account-Name/Repo-2-Name"
    # }

  }
}
module "vpc" {
  source                   = "./modules/vpc"
  second_octet             = var.second_octet
  no_of_availability_zones = var.no_of_availability_zones
  environment              = var.environment

}

module "dns" {
  source       = "./modules/dns"
  alb_dns_name = module.alb.alb_dns_name
  alb_zone_id  = module.alb.alb_zone_id
}

module "acm" {
  # depends_on     = [module.dns]
  source = "./modules/acm"
  # subdomain_name = module.dns.subdomain_name
  # environment = var.environment
}

module "iam" {
  source = "./modules/iam"
}

module "alb" {
  source           = "./modules/alb"
  environment      = var.environment
  depends_on       = [module.acm]
  vpc_id           = module.vpc.vpc_id
  subnets          = module.vpc.public_subnets_id
  whitelisted_ips  = var.whitelisted_ips
  is_internal      = var.is_internal
  alb_tls_cert_arn = module.acm.acm_certificate_arn
}

module "security_group" {
  source      = "./modules/securityGroup"
  environment = var.environment
  vpc_id      = module.vpc.vpc_id
  alb_sg      = module.alb.alb_security_group_id
  # wildfly_instance_sg_id = module.wildfly_instance.wildfly_instance_sg_id
}

module "target_group" {
  source       = "./modules/targetGroup"
  vpc_id       = module.vpc.vpc_id
  listener_arn = module.alb.listener_arn
}

module "webServer" {
  source                  = "./modules/webServer"
  aws_lb_target_group_arn = module.target_group.target_group_arn
  security_groups         = module.security_group.java_app_sg_id
  instance_profile        = module.iam.cw_agent_ssm_instance_profile
  subnets                 = module.vpc.private_subnets_id
  # wildfly_instance_sg_id =
}

module "codeDeploy" {
  source               = "./modules/codeDeploy"
  asg_name             = module.webServer.webserver_instance_ids
  code_deploy_role_arn = module.iam.codedeploy_role_arn
}

module "codeBuild" {
  source         = "./modules/codeBuild"
  codebuild_role = module.iam.codebuild_role_arn
}

module "codePipeline" {
  source                           = "./modules/codePipeline"
  kms_key_arn                      = module.codeBuild.kms_alias_key_arn
  for_each                         = local.deployment
  repository_in                    = each.value.repo
  name_in                          = each.key
  sns_topic_arn                    = module.codeDeploy.sns_topic_arn
  codebuild_project_name           = module.codeBuild.codebuild_project_name
  codedeploy_app_name              = module.codeDeploy.codedeploy_app_name
  codedeploy_deployment_group_name = module.codeDeploy.codedeploy_group_name
  code_pipeline_role_arn           = module.iam.codepipeline_role_arn
}
