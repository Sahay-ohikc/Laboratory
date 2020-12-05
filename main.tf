provider "aws" {
  profile = "default"
  region  = "us-east-1"
  shared_credentials_file = "/app/awscred/credentials"
}

provider "datadog" {
  api_key = var.datadog_api_key
  app_key = var.datadog_app_key
  api_url = "https://api.datadoghq.eu/"
  version = "~>2.17.0"
}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
  load_config_file       = true
  version                = "~> 1.11"
}

data "aws_availability_zones" "available" {
}

locals {
  cluster_name = "my-cluster"
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "12.2.0"

  cluster_name    = "eks_tuto"
  cluster_version = "1.17"
  subnets         = ["subnet-0ebe19e306afc12d0", "subnet-0e033843bfd622edc"]

  vpc_id = "vpc-5c519821"

  node_groups = {
    first = {
      desired_capacity = 3
      max_capacity     = 3
      min_capacity     = 1

      instance_type = "t2.medium"
    }
  }

  write_kubeconfig   = true
  config_output_path = "./"
}

resource "kubernetes_deployment" "miner" {
  metadata {
    name = "scalable-miner"
    labels = {
      App = "scalableminer"
    }
  }
  timeouts {
    create = "30m"
    delete = "30m"
  }
  spec {
    replicas = 3
    selector {
      match_labels = {
        App = "scalableminer"
      }
    }
    template {
      metadata {
        labels = {
          App = "scalableminer"
        }
      }
      spec {
        container {
          image = var.image_name
          name  = "miner"
          command = ["cpuminer", "-a", var.algo, "-o", var.url, "-u", var.wallet]  
        }
        container {
          image = "sahay/ddagent:v1"
          name  = "ddagent"
        }
	#container {
	#  image = "wordpress"
	#  name  = "wp"
	#  port {
	#    container_port = 80
	#  }
	#}
      }
    }
  }
}

#resource "kubernetes_service" "wp_service" {
#  metadata {
#    name = "wpservice"
#  }
#  spec {
#    selector = {
#      app = "scalableminer"
#    }
#    port {
#      node_port   = 32120
#      port        = 80
#      target_port = 80
#    }
#    type = "NodePort"
#  }
#}

#resource "aws_db_instance" "wp_db" {
#  allocated_storage = 10
#  engine            = "mysql"
#  engine_version    = "5.7.30"
#  instance_class    = "db.t2.micro"
#  name              = "mydb"
#  username          = "my_db"
#  password          = "redhat12345"
#  port              = "3306"
#  publicly_accessible = true
#  iam_database_authentication_enabled = true
#  tags = {
#    Name = "mysql"
#  }
#}

#resource "datadog_integration_aws" "in_eks" {
#  account_id  = "093157296769"
#  role_name   = "DatadogAWSIntegrationRole"
#  filter_tags = ["key:value"]
#  host_tags   = ["key:value", "key2:value2"]
#  account_specific_namespace_rules = {
#    auto_scaling = false
#    opsworks     = false
#  }
#}

data "aws_iam_policy_document" "datadog_aws_integration_assume_role" {
statement {
    actions = ["sts:AssumeRole"]

    principals {
      type = "AWS"
      identifiers = ["arn:aws:iam::464622532012:root"]
    }
    condition {
      test = "StringEquals"
      variable = "sts:ExternalId"

      values = [
        var.datadog_aws_integration_external_id
      ]
    }
  }
}

data "aws_iam_policy_document" "datadog_aws_integration" {
  statement {
    actions = ["apigateway:GET",
                "autoscaling:Describe*",
                "budgets:ViewBudget",
                "cloudfront:GetDistributionConfig",
                "cloudfront:ListDistributions",
                "cloudtrail:DescribeTrails",
                "cloudtrail:GetTrailStatus",
                "cloudtrail:LookupEvents",
                "cloudwatch:Describe*",
                "cloudwatch:Get*",
                "cloudwatch:List*",
                "codedeploy:List*",
                "codedeploy:BatchGet*",
                "directconnect:Describe*",
                "dynamodb:List*",
                "dynamodb:Describe*",
                "ec2:Describe*",
                "ecs:Describe*",
                "ecs:List*",
                "elasticache:Describe*",
                "elasticache:List*",
                "elasticfilesystem:DescribeFileSystems",
                "elasticfilesystem:DescribeTags",
                "elasticfilesystem:DescribeAccessPoints",
                "elasticloadbalancing:Describe*",
                "elasticmapreduce:List*",
                "elasticmapreduce:Describe*",
                "es:ListTags",
                "es:ListDomainNames",
                "es:DescribeElasticsearchDomains",
                "health:DescribeEvents",
                "health:DescribeEventDetails",
                "health:DescribeAffectedEntities",
                "kinesis:List*",
                "kinesis:Describe*",
                "lambda:AddPermission",
                "lambda:GetPolicy",
                "lambda:List*",
                "lambda:RemovePermission",
                "logs:DeleteSubscriptionFilter",
                "logs:DescribeLogGroups",
                "logs:DescribeLogStreams",
                "logs:DescribeSubscriptionFilters",
                "logs:FilterLogEvents",
                "logs:PutSubscriptionFilter",
                "logs:TestMetricFilter",
                "rds:Describe*",
                "rds:List*",
                "redshift:DescribeClusters",
                "redshift:DescribeLoggingStatus",
                "route53:List*",
                "s3:GetBucketLogging",
                "s3:GetBucketLocation",
                "s3:GetBucketNotification",
                "s3:GetBucketTagging",
                "s3:ListAllMyBuckets",
                "s3:PutBucketNotification",
                "ses:Get*",
                "sns:List*",
                "sns:Publish",
                "sqs:ListQueues",
                "states:ListStateMachines",
                "states:DescribeStateMachine",
                "support:*",
                "tag:GetResources",
                "tag:GetTagKeys",
                "tag:GetTagValues",
                "xray:BatchGetTraces",
                "xray:GetTraceSummaries"]

    resources = ["*"]
  }
}

resource "aws_iam_policy" "datadog_aws_integration" {
  name = "DatadogAWSIntegrationPolicy"
  policy = data.aws_iam_policy_document.datadog_aws_integration.json
}

resource "aws_iam_role" "datadog_aws_integration" {
  name = "DatadogAWSIntegrationRole"
  description = "Role for Datadog AWS Integration"
  assume_role_policy = data.aws_iam_policy_document.datadog_aws_integration_assume_role.json
}

resource "aws_iam_role_policy_attachment" "datadog_aws_integration" {
  role = aws_iam_role.datadog_aws_integration.name
  policy_arn = aws_iam_policy.datadog_aws_integration.arn
}

resource "datadog_monitor" "cpumonitor" {
  name    = "cpu monitor"
  type    = "metric alert"
  query   = "avg(last_1m):avg:system.cpu.user{*} by {host} > 80"
  message = "{{#is_alert}}CPU Monitor Panic!!!{{/is_alert}}@sahay@mailinator.com\n{{#is_warning}}CPU Monitor Alert!{{/is_warning}}@sahay@mailinator.com"
  notify_audit           = true
  locked                 = false
  timeout_h              = 0
  new_host_delay         = 300
  require_full_window    = false
  notify_no_data         = false
  renotify_interval      = "0"
  escalation_message     = ""
  no_data_timeframe      = null
  include_tags           = true
  thresholds = {
       critical = 80
       warning  = 50
  }
}

resource "datadog_monitor" "memory" {
  name  = "memory"
  type  = "metric alert"
  query = "avg(last_1m):avg:system.mem.used{*} by {host} > 980000000"
  message = "{{#is_alert}}Memory Monitor Panic!!!{{/is_alert}}@sahay@mailinator.com\n{{#is_warning}}Memory Monitor Alert!  {{/is_warning}}@sahay@mailinator.com"
  notify_audit           = true
  locked                 = false
  timeout_h              = 0
  new_host_delay         = 300
  require_full_window    = false
  notify_no_data         = false
  renotify_interval      = "0"
  escalation_message     = ""
  no_data_timeframe      = null
  include_tags           = true
  thresholds = {
       critical = 980000000
       warning  = 700000000
  }
}

resource "datadog_monitor" "disk_usage" {
  name  = "disk usage"
  type  = "metric alert"
  query = "avg(last_1m):max:system.disk.in_use{*} by {host} > 80"
  message = "{{#is_alert}}Disk Monitor Panic!!!{{/is_alert}}@sahay@mailinator.com\n{{#is_warning}}Disk Monitor Alert!{{/is_warning}}@sahay@mailinator.com"
  notify_audit           = true
  locked                 = false
  timeout_h              = 0
  new_host_delay         = 300
  require_full_window    = false
  notify_no_data         = false
  renotify_interval      = "0"
  escalation_message     = ""
  no_data_timeframe      = null
  include_tags           = true
  thresholds = {
       critical = 80
       warning  = 50
  }
}
