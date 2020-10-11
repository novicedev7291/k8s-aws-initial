# etcd cluster instances for k8s key-value & configuration store

resource "aws_instance" "etcd" {
    count = 2
    ami = lookup(var.amis, var.region)
    instance_type = var.etcd_type

    subnet_id = aws_subnet.k8s-subnet.id
    private_ip = cidrhost(var.cidr_block, 10 + count.index)
    associate_public_ip_address = true # Dynamic ip assigned by aws

    availability_zone = var.zone
    vpc_security_group_ids = [aws_security_group.k8s-sg.id]
    key_name = var.default_keypair_name

    tags = {
        Name = "etcd-${count.index}"
    }
}
