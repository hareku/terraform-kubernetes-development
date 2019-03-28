####################################
# EKS
####################################
module "cluster" {
  source             = "terraform-aws-modules/eks/aws"
  cluster_name       = "${local.project_name}-cluster"
  cluster_version    = "1.11"
  vpc_id             = "${local.dev_vpc_id}"
  config_output_path = "./config/"
  subnets            = "${local.dev_subnets}"

  workers_group_defaults = {
    public_ip           = true
    autoscaling_enabled = true
  }

  worker_group_count = "2"

  worker_groups = [
    {
      name               = "spot_group"
      instance_type      = "m4.2xlarge"
      spot_price         = "0.5"
      asg_max_size       = 20
      asg_min_size       = 0
      subnets            = "${local.dev_subnet_a}"
      kubelet_extra_args = "--node-labels=${local.spot_label}=true"
    },
    {
      name               = "ondemand_group"
      instance_type      = "t3.small"
      asg_max_size       = 3
      subnets            = "${local.dev_subnet_d}"
      kubelet_extra_args = "--node-labels=${local.ondemand_label}=true"
    },
  ]

  worker_group_tags = {
    spot_group = [
      {
        key                 = "k8s.io/cluster-autoscaler/node-template/label/${local.spot_label}"
        value               = "true"
        propagate_at_launch = true
      },
    ]

    ondemand_group = []
  }

  tags = "${local.resource_default_tags}"
}

# internal system sg -> worker sg (for dashboard alb)
resource "aws_security_group_rule" "internal_system_to_worker_instance" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "tcp"
  security_group_id        = "${module.cluster.worker_security_group_id}"
  source_security_group_id = "${local.internal_system_security_group_id}"
}

# dev-alb sg -> worker sg (for merged dev app alb)
resource "aws_security_group_rule" "dev_alb_to_worker_instance" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "tcp"
  security_group_id        = "${module.cluster.worker_security_group_id}"
  source_security_group_id = "${local.dev_alb_security_group_id}"
}
