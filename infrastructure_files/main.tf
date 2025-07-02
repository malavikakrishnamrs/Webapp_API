provider "aws" {
  region = "us-east-1"
}

module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  cluster_name    = "sample-cluster"
  subnets         = ["subnet-1", "subnet-2"]
  vpc_id          = "vpc-sample"
  enable_irsa     = true
  node_groups = {
    default = {
      desired_capacity = 2
      max_capacity     = 3
      min_capacity     = 1
    }
  }
}
