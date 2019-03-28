resource "helm_release" "ingress_merge" {
  name      = "ingress-merge"
  chart     = "${path.module}/helm/ingress-merge/helm"
  namespace = "kube-system"

  values = [
    <<EOF
nodeSelector:
  ${local.ondemand_label}: "true"
EOF
    ,
  ]
}

resource "kubernetes_config_map" "merged_ingress_for_dev_app" {
  metadata {
    name      = "merged-ingress-for-dev-app"
    namespace = "default"
  }

  data {
    annotations = <<EOF
kubernetes.io/ingress.class: alb
alb.ingress.kubernetes.io/scheme: internet-facing
alb.ingress.kubernetes.io/subnets: ${join(",", local.dev_subnets)}
alb.ingress.kubernetes.io/security-groups: ${local.dev_base_security_group_id}
alb.ingress.kubernetes.io/certificate-arn: ${join(",", concat(
  aws_acm_certificate.my_app.*.arn,
))}
alb.ingress.kubernetes.io/listen-ports: '[{"HTTP": 80}, {"HTTPS":443}]'
alb.ingress.kubernetes.io/actions.ssl-redirect: '{"Type": "redirect", "RedirectConfig": { "Protocol": "HTTPS", "Port": "443", "StatusCode": "HTTP_301"}}'
alb.ingress.kubernetes.io/healthcheck-interval-seconds: '60'
EOF
  }

  depends_on = [
    "helm_release.ingress_merge",
  ]
}
