provider "aws" {
  profile = "default"
  region  = "us-east-1"
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
  load_config_file       = false
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
      desired_capacity = 5
      max_capacity     = 5
      min_capacity     = 1

      instance_type = "t2.micro"
    }
  }

  write_kubeconfig   = true
  config_output_path = "./"
}

resource "kubernetes_deployment" "miner" {
  metadata {
    name = "scalable-miner"
    labels = {
      App = "ScalableMiner"
    }
  }

  spec {
    replicas = 5
    selector {
      match_labels = {
        App = "ScalableMiner"
      }
    }
    template {
      metadata {
        labels = {
          App = "ScalableMiner"
        }
      }
      spec {
        container {
          image = "${var.image_name}"
          name  = "miner"
          command = ["cpuminer", "-a", "${var.algo}", "-o", "${var.url}", "-u", "${var.wallet}"]  
          port {
            container_port = 80
          }
        }
      }
    }
  }
}
