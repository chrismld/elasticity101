variable "config" {
  type = object({
    profile = string
    region  = string
  })
  default = {
    profile = "christian-admin"
    region  = "eu-west-1"
  }
}

variable "resource_names" {
  type = object({
    vpc          = string
    igw          = string
    route_tables = map(string)
    subnets = object({
      private = map(string)
      public  = map(string)
    })
    security_groups = map(string)
    role            = string
    profile         = string
    target_group  = string
    load_balancer = string
  })
  default = {
    vpc = "kc-aws-test-vpc"
    igw = "kc-aws-test-igw"
    route_tables = {
      private = "kc-aws-test-private-rt"
      public  = "kc-aws-test-public-rt"
    }
    subnets = {
      private = {
        a = "kc-aws-test-private-subnet-1"
        b = "kc-aws-test-private-subnet-2"
      }
      public = {
        a = "kc-aws-test-public-subnet-1"
        b = "kc-aws-test-public-subnet-1"
      }
    }
    security_groups = {
      ec2 = "kc-aws-test-webapp-sg"
      alb = "kc-aws-test-alb-sg"
    }
    role         = "kc-aws-test-ec2-role"
    profile      = "kc-aws-test-ec2-profile"
    target_group  = "kc-aws-test-webapp-tg"
    load_balancer = "kc-aws-test-webapp-alb"
  }
}
