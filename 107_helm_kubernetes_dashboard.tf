resource "helm_release" "kubernetes_dashboard" {
  name       = "kubernetes-dashboard"
  repository = "stable"
  chart      = "kubernetes-dashboard"
  version    = "1.2.0"
  namespace  = "kube-system"

  values = [
    <<EOF
extraArgs:
  - --token-ttl=0

service:
  type: NodePort

nodeSelector:
  ${local.ondemand_label}: "true"

ingress:
  enabled: true
  hosts:
    - ${aws_acm_certificate.kubernetes_dashboard.domain_name}
  paths:
    - /
    - /*
  annotations:
    kubernetes.io/ingress.class: alb
    alb.ingress.kubernetes.io/scheme: internet-facing
    alb.ingress.kubernetes.io/certificate-arn: ${aws_acm_certificate.kubernetes_dashboard.arn}
    alb.ingress.kubernetes.io/backend-protocol: HTTPS
    alb.ingress.kubernetes.io/healthcheck-protocol: HTTPS
    alb.ingress.kubernetes.io/subnets: ${join(",", local.dev_subnets)}
    alb.ingress.kubernetes.io/security-groups: ${local.internal_system_security_group_id}
EOF
    ,
  ]
}

resource "aws_acm_certificate" "kubernetes_dashboard" {
  domain_name       = "${local.kubernetes_dashboard_domain}"
  validation_method = "DNS"
}

resource "aws_route53_record" "kubernetes_dashboard_acm_certificate" {
  count   = "${length(aws_acm_certificate.kubernetes_dashboard.domain_validation_options)}"
  zone_id = "${local.dev_apex_domain_public_hosted_zone_id}"
  name    = "${lookup(aws_acm_certificate.kubernetes_dashboard.domain_validation_options[count.index],"resource_record_name")}"
  type    = "${lookup(aws_acm_certificate.kubernetes_dashboard.domain_validation_options[count.index],"resource_record_type")}"
  ttl     = "300"
  records = ["${lookup(aws_acm_certificate.kubernetes_dashboard.domain_validation_options[count.index],"resource_record_value")}"]
}
