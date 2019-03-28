locals {
  aws_region      = "ap-northeast-1"
  project_name    = "my-company-dev"             // use hyphen insted of underscore, etc
  resource_prefix = "my-company-dev-cluster-eks"

  resource_default_tags = {
    Environment = "Development"
  }

  dev_vpc_id   = "vpc-xxxxx"
  dev_subnet_a = "subnet-xxxxx"
  dev_subnet_c = "subnet-xxxxx"
  dev_subnet_d = "subnet-xxxxx"

  dev_alb_security_group_id         = "sg-xxxxx"
  internal_system_security_group_id = "sg-xxxxx"

  dev_apex_domain                       = "my-company.com"
  dev_apex_domain_public_hosted_zone_id = "ABCDEFGHIJKLMN"

  ondemand_label = "ondemand"
  spot_label     = "spot"
}

// domains
locals {
  kubernetes_dashboard_domain = "${local.project_name}-k8s-dashboard.${local.dev_apex_domain}"
}

// local variables for utils
locals {
  dev_subnets = [
    "${local.dev_subnet_a}",
    "${local.dev_subnet_c}",
    "${local.dev_subnet_d}",
  ]
}

// developers
locals {
  developers = [
    {
      name = "your.name"
    },
    {
      name = "my.name"
    },
  ]
}
