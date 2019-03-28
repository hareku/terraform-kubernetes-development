resource "helm_release" "efs_provisioner" {
  name       = "efs-provisioner"
  repository = "stable"
  chart      = "efs-provisioner"
  version    = "0.3.4"
  namespace  = "kube-system"

  values = [
    <<EOF
rbac:
  create: true

nodeSelector:
  ${local.spot_label}: "true"

efsProvisioner:
  efsFileSystemId: ${aws_efs_file_system.dev_resources.id}
  awsRegion: ${local.aws_region}
  path: /
  provisionerName: dev-resources
  storageClass:
    reclaimPolicy: Retain
EOF
    ,
  ]
}
