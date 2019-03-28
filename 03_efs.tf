####################################
# EFS
####################################
resource "aws_efs_file_system" "dev_resources" {
  encrypted        = false
  performance_mode = "generalPurpose"
  throughput_mode  = "bursting"
  tags             = "${merge(local.resource_default_tags, map("Name", "${local.resource_prefix}_dev-resources"))}"
}

resource "aws_efs_mount_target" "dev_resources" {
  count           = "${length(local.dev_subnets)}"
  file_system_id  = "${aws_efs_file_system.dev_resources.id}"
  subnet_id       = "${element(local.dev_subnets, count.index)}"
  security_groups = ["${aws_security_group.efs_dev_resources_mount_target.id}"]
}

####################################
# EFS mount target's Security Group
####################################
resource "aws_security_group" "efs_dev_resources_mount_target" {
  name        = "${local.resource_prefix}_efs-dev-resources-mount-target"
  description = "${local.resource_prefix}_efs-dev-resources-mount-target"
  vpc_id      = "${local.dev_vpc_id}"

  ingress {
    from_port = 2049
    to_port   = 2049
    protocol  = "tcp"

    security_groups = [
      "${module.cluster.worker_security_group_id}",
    ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = "${merge(local.resource_default_tags, map("Name", "${local.resource_prefix}_efs-dev-resources-mount-target"))}"
}
