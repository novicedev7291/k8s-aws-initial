# Create key-pair to access instance
resource "aws_key_pair" "default" {
    key_name = "cloudops-default"
    public_key = var.default_public_key
}