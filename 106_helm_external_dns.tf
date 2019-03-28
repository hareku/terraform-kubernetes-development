#####################################
# Helm: ExternalDNS
#####################################
resource "helm_release" "external_dns" {
  name       = "external-dns"
  repository = "stable"
  chart      = "external-dns"
  version    = "1.6.1"
  namespace  = "kube-system"

  values = [
    <<EOF
provider: aws

aws:
  region: ${local.aws_region}
  zoneType: public

domainFilters:
  - ${local.dev_apex_domain}

rbac:
  create: true

podAnnotations:
  iam.amazonaws.com/role: ${aws_iam_role.external_dns.arn}

nodeSelector:
  ${local.ondemand_label}: "true"

resources:
  limits:
    cpu: 50m
    memory: 50Mi
  requests:
    cpu: 50m
    memory: 50Mi
EOF
    ,
  ]
}

#####################################
# IAM: ExternalDNS
#####################################
resource "aws_iam_role" "external_dns" {
  name               = "${local.resource_prefix}_external_dns"
  assume_role_policy = "${data.aws_iam_policy_document.kube2iam_assume_role_policy_for_pods.json}"
}

resource "aws_iam_policy" "external_dns" {
  name = "${local.resource_prefix}_external_dns"

  policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
   {
     "Effect": "Allow",
     "Action": [
       "route53:ChangeResourceRecordSets"
     ],
     "Resource": [
       "arn:aws:route53:::hostedzone/${local.dev_apex_domain_public_hosted_zone_id}"
     ]
   },
   {
     "Effect": "Allow",
     "Action": [
       "route53:ListHostedZones",
       "route53:ListResourceRecordSets"
     ],
     "Resource": [
       "*"
     ]
   }
 ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "external_dns" {
  role       = "${aws_iam_role.external_dns.name}"
  policy_arn = "${aws_iam_policy.external_dns.arn}"
}
