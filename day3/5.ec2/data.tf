# Fetch user data script from SSM Parameter Store
data "aws_ssm_parameter" "userdata" {
  name = local.userdata_ssm_path
  with_decryption = true
}

# Fetch the latest Amazon Linux 2023 AMI using the filter defined in locals
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = [local.ami_name_filter]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}
