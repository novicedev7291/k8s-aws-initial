# k8s controller instances

resource "aws_instance" "controller" {
    count = 2
    ami = lookup(var.amis, var.region)
    instance_type = var.controller_type

    subnet_id = aws_subnet.k8s-subnet.id
    private_ip = cidrhost(var.cidr_block, 20 + count.index)
    associate_public_ip_address = true # Dynamic ip by aws
    source_dest_check = false

    availability_zone = var.zone
    vpc_security_group_ids = [aws_security_group.k8s-sg.id]
    key_name = var.default_keypair_name

    tags = {
        Name = "controller-${count.index}"
    }
}

# k8s API load balancer

resource "aws_elb" "k8s_api" {
    name = "k8s-api-elb"
    instances = aws_instance.controller.*.id
    subnets = [aws_subnet.k8s-subnet.id]
    cross_zone_load_balancing = false

    security_groups = [aws_security_group.k8s_api_sg.id]

    listener {
        lb_port = 6443
        instance_port = 6443
        lb_protocol = "TCP"
        instance_protocol = "TCP"
    }

    health_check {
        healthy_threshold = 2
        unhealthy_threshold = 2
        timeout = 15
        target = "HTTP:8080/healthz"
        interval = 30
    }

    tags = {
        Name = "k8s_elb"
    }
}

# k8s API load balancer secutiry group

resource "aws_security_group" "k8s_api_sg" {
    name = "k8s-api"
    vpc_id = aws_vpc.kubernetes.id

    # Allow inbound traffic to the port used by kubernetes API HTTPS
    ingress {
        from_port = 6443
        to_port = 6443
        protocol = "TCP"
        cidr_blocks = [var.control_cidr]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "k8s-api-sg"
    }
}

# Output k8s API elb dns name
output "k8s_api_dns_name" {
    value = aws_elb.k8s_api.dns_name
}