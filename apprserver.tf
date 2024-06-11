resource "aws_key_pair" "private" {
  key_name   = var.appserver_config.key_name
  public_key = file(var.appserver_config.public_key_path)

  tags = {
    CreatedBy = "terraform"
  }

}

data "aws_subnet" "app" {
  filter {
    name   = "tag:Name"
    values = [var.app_subnet_name]
  }
  depends_on = [
    aws_subnet.subnets
  ]
}

resource "aws_instance" "app" {
  ami                         = var.appserver_config.ubuntu_ami_id
  associate_public_ip_address = true
  instance_type               = var.appserver_config.ec2_instance_size
  key_name                    = aws_key_pair.private.key_name
  subnet_id                   = data.aws_subnet.app.id
  vpc_security_group_ids      = [aws_security_group.appnsg.id]

  tags = {
    Name = "appserver"
  }

  depends_on = [
    aws_vpc.ntier_vpc,
    aws_subnet.subnets,
    aws_security_group.appnsg,
    aws_key_pair.private
  ]

}