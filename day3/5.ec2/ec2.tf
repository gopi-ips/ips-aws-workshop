resource "aws_instance" "ec2" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type

  vpc_security_group_ids = [aws_security_group.ec2.id]

  user_data = data.aws_ssm_parameter.userdata.value

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-ec2"
  })
}
