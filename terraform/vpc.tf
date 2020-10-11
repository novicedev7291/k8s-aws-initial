# Create a vpc

resource "aws_vpc" "kubernetes" {
    cidr_block = var.cidr_block
    enable_dns_hostnames = true

    tags = {
        Name = var.vpc_name
    }
}

# Create a DHCP options set but it would be similar to the default one by aws
# This is to just show that it can be define and link with created vpc

resource "aws_vpc_dhcp_options" "dns_resolver" {
    domain_name = "${var.region}.compute.internal"
    domain_name_servers = ["AmazonProvidedDNS"]

    tags = {
        Name = var.dhcp_option_set_name
    }
}

resource "aws_vpc_dhcp_options_association" "dns_resolver" {
    vpc_id = aws_vpc.kubernetes.id
    dhcp_options_id = aws_vpc_dhcp_options.dns_resolver.id
}

# Create a single subnet to be used for whole vpc cidr block
# Public subnet
resource "aws_subnet" "k8s-subnet" {
    vpc_id = aws_vpc.kubernetes.id
    cidr_block = var.cidr_block
    availability_zone = var.zone

    tags = {
        Name = var.subnet_name
    }
}

# Create a internet gateway to attach with subnet so that the traffic can be
# route to the public
resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.kubernetes.id

    tags = {
        Name = var.igw_name
    }
}

# Routing 
resource "aws_route_table" "k8s-routing-table" {
    vpc_id = aws_vpc.kubernetes.id

    # Default route through internet gatway
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw.id
    }

    tags = {
        Name = var.routing_table_name
    }
}

resource "aws_route_table_association" "k8s-routing-table-assoc" {
    subnet_id = aws_subnet.k8s-subnet.id
    route_table_id = aws_route_table.k8s-routing-table.id
}

# Security 
resource "aws_security_group" "k8s-sg" {
    vpc_id = aws_vpc.kubernetes.id
    name = "k8s-sg"

    # Allow all outbound
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    # Allow all internal vpc communication
    ingress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = [var.cidr_block]
    }

    # Allow all traffic kubernetes API elb
    ingress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        security_groups = [aws_security_group.k8s_api_sg.id]
    }

    tags = {
        Name = "k8s-sg"
    }
}

