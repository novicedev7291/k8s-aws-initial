# k83 worker nodes aka minion aka instances which runs pods

resource "aws_instance" "worker" {
    count = 3
    ami = lookup(var.amis, var.region)
    instance_type = var.worker_type

    subnet_id = aws_subnet.k8s-subnet.id
    private_ip = cidrhost(var.cidr_block, 30 + count.index)
    associate_public_ip_address = true
    source_dest_check = false

    availability_zone = var.zone
    key_name = var.default_keypair_name
    vpc_security_group_ids = [aws_security_group.k8s-sg.id]

    tags = {
        Name = "worker-${count.index}"
    }
}

output "k8s_worker_public_ips" {
    value = [join(",", aws_instance.worker.*.public_ip)]
}