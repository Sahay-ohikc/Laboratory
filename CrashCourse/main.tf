data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

locals {
  cluster_name = "eks-crash"
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "12.2.0"

  cluster_name    = "eks-crash"
  cluster_version = "1.17"
  subnets         = [aws_subnet.public1.id, aws_subnet.public2.id]

  vpc_id = aws_vpc.vpc.id

  node_groups = {
    first = {
      desired_capacity = 3
      max_capacity     = 3
      min_capacity     = 1

      instance_type = "t2.medium"
    }
  }

  write_kubeconfig   = true
  manage_aws_auth = false
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
        #container {
        #  image = "sahay/ddagent:v2"
        #  name  = "ddagent"
        #}
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


