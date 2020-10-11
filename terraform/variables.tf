variable "region" {
    default = "us-east-1"
}

# Instances types
variable "etcd_type" {
    type = string
    default = "t2.micro"
}

variable "worker_type" {
    type = string
    default = "t2.micro"
}

variable "controller_type" {
    type = string
    default = "t2.micro"
}

# Networking variables

variable "zone" {
    default = "us-east-1a"
}

variable "vpc_name" {
    default = "k8s"
}

variable "cidr_block" {
    default = "10.45.0.0/16"
}

variable "dhcp_option_set_name" {
    default = "k8s-dhcp-option-set"
}

variable "subnet_name" {
    type = string
    default = "k8s subnet"
}

variable "igw_name" {
    type = string
    default = "k8s internet gateway"
}

variable "routing_table_name" {
    default = "k8s main routing table"
}

# Default key pair name
variable "default_public_key" {
    description = "Public key part of public-private key pair"
}

variable "default_keypair_name" {
    default = "cloudops-default"
}

# AMIs map by regions
variable "amis" {
    type = map
    default = {
        us-east-1 = "ami-0817d428a6fb68645"
    }
}



# kuebernetes controller APIs access from given IPS
variable "control_cidr" {}