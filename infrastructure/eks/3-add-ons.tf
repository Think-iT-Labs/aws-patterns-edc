locals {
  addons_namespace                 = "kube-system"
  aws_lbc_service_account          = "aws-load-balancer-controller"
  aws_ebs_csic_service_account     = "ebs-csi-controller-sa"
  external_dns_service_account     = "external-dns"
  external_secrets_service_account = "external-secrets"
}

##############################################
#  Kubernetes Metrics Server Add-on
##############################################

resource "helm_release" "metrics_server" {
  name        = "metrics-server"
  description = "Kubernetes Metrics Server for collecting resource metrics"

  repository  = "https://kubernetes-sigs.github.io/metrics-server/"
  chart       = "metrics-server"
  namespace   = local.addons_namespace
  version     = var.metrics_server_chart_version
  max_history = 3

  values = [file("${path.module}/resources/helm/templates/metrics-server.yaml")]

  depends_on = [aws_eks_node_group.eks_worker_nodes]
}

##############################################
#  EKS Pod Identity AWS Add-on
##############################################

resource "aws_eks_addon" "pod_identity" {
  cluster_name  = aws_eks_cluster.eks_cluster.name
  addon_name    = "eks-pod-identity-agent"
  addon_version = var.pod_identity_addon_version

  tags = {
    Tier     = "eks-addon"
    Category = "observability"
  }
}

##############################################
# AWS Load Balancer Controller Add-on
##############################################

resource "aws_iam_role" "aws_lbc" {
  name = "${aws_eks_cluster.eks_cluster.name}-aws-lbc"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "sts:AssumeRole",
          "sts:TagSession"
        ]
        Principal = {
          Service = "pods.eks.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Tier = "iam"
  }
}

resource "aws_iam_policy" "aws_lbc" {
  policy = file("./resources/iam/policies/aws-lb-controller.json")
  name   = "AWSLoadBalancerController"

  tags = {
    Tier = "iam"
  }
}

resource "aws_iam_role_policy_attachment" "aws_lbc" {
  policy_arn = aws_iam_policy.aws_lbc.arn
  role       = aws_iam_role.aws_lbc.name
}

resource "aws_eks_pod_identity_association" "aws_lbc" {
  cluster_name    = aws_eks_cluster.eks_cluster.name
  namespace       = local.addons_namespace
  service_account = local.aws_lbc_service_account
  role_arn        = aws_iam_role.aws_lbc.arn

  tags = {
    Tier = "iam"
  }
}

resource "helm_release" "aws_lbc" {
  name = "aws-load-balancer-controller"

  repository  = "https://aws.github.io/eks-charts"
  chart       = "aws-load-balancer-controller"
  namespace   = local.addons_namespace
  version     = var.aws_lbc_chart_version
  max_history = 3


  values = [
    templatefile("${path.module}/resources/helm/templates/aws-lbc.yaml", {
      cluster_name    = aws_eks_cluster.eks_cluster.name
      service_account = local.aws_lbc_service_account
      vpc_id          = aws_vpc.main.id
    })
  ]

  depends_on = [helm_release.metrics_server]
}

##############################################
# External DNS Add-on
##############################################

resource "aws_iam_role" "external_dns" {
  name = "${aws_eks_cluster.eks_cluster.name}-external-dns"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "sts:AssumeRole",
          "sts:TagSession"
        ]
        Effect = "Allow"
        Principal = {
          Service = "pods.eks.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    Tier = "iam"
  }
}

resource "aws_iam_policy" "external_dns" {
  policy = file("./resources/iam/policies/external-dns.json")
  name   = "AllowExternalDNSUpdates"

  tags = {
    Tier = "iam"
  }
}

resource "aws_iam_role_policy_attachment" "external_dns" {
  policy_arn = aws_iam_policy.external_dns.arn
  role       = aws_iam_role.external_dns.name
}

resource "aws_eks_pod_identity_association" "external_dns" {
  cluster_name    = aws_eks_cluster.eks_cluster.name
  namespace       = local.addons_namespace
  service_account = local.external_dns_service_account
  role_arn        = aws_iam_role.external_dns.arn

  tags = {
    Tier = "iam"
  }
}

resource "helm_release" "external_dns" {
  name = "external-dns"

  repository  = "https://kubernetes-sigs.github.io/external-dns/"
  chart       = "external-dns"
  namespace   = local.addons_namespace
  version     = var.external_dns_chart_version
  max_history = 3


  values = [
    templatefile("${path.module}/resources/helm/templates/external-dns.yaml", {
      external_dns_policy = "sync"
      domain_name         = var.domain_name
      service_account     = local.external_dns_service_account
    })
  ]

  depends_on = [helm_release.aws_lbc]
}
