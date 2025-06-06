resource "aws_instance" "ec2" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  key_name                    = var.key_name
  vpc_security_group_ids      = [aws_security_group.sg.id]
  subnet_id                   = var.subnet_id
  associate_public_ip_address = true
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name
  
  root_block_device {
    volume_size = var.volume_size
  }
  # user_data = 

}

resource "aws_security_group" "sg" {
  name        = "${var.instance_name}-sg"
  description = "Security group for ${var.instance_name} EC2 instance"
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = var.inbound_ports
    content {
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = var.allowed_cidr_blocks
      description = ingress.value.description
    }
  }

  # Outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = merge(
    {
      Name = "${var.instance_name}-sg"
    },
    var.tags
  )
}
