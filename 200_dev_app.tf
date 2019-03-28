resource "helm_release" "my_app" {
  count     = "${length(local.developers)}"
  name      = "${replace(lookup(local.developers[count.index], "name"), ".", "-")}-my-app"
  chart     = "${path.module}/helm/dev-app"
  namespace = "default"
  wait      = false

  values = [
    <<EOF
userName: ${lookup(local.developers[count.index], "name")}
hostName: ${element(aws_acm_certificate.my_app.*.domain_name, count.index)}
nodeSelector:
  ${local.spot_label}: "true"
EOF
    ,
  ]
}

resource "aws_acm_certificate" "my_app" {
  count             = "${length(local.developers)}"
  domain_name       = "my-app.com.${lookup(local.developers[count.index], "name")}.${local.dev_apex_domain}"
  validation_method = "DNS"
}

locals {
  my_app_acm_certificate_validation_options = "${flatten(aws_acm_certificate.my_app.*.domain_validation_options)}"
}

resource "aws_route53_record" "my_app_acm_certificate" {
  count   = "${length(local.developers)}"
  zone_id = "${local.dev_apex_domain_public_hosted_zone_id}"
  name    = "${lookup(local.my_app_acm_certificate_validation_options[count.index],"resource_record_name")}"
  type    = "${lookup(local.my_app_acm_certificate_validation_options[count.index],"resource_record_type")}"
  ttl     = "300"
  records = ["${lookup(local.my_app_acm_certificate_validation_options[count.index],"resource_record_value")}"]
}
