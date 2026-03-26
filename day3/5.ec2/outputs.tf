output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.ec2.id
}

output "instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.ec2.public_ip
}

output "instance_private_ip" {
  description = "Private IP address of the EC2 instance"
  value       = aws_instance.ec2.private_ip
}

output "instance_type" {
  description = "EC2 instance type used"
  value       = aws_instance.ec2.instance_type
}

output "ami_id" {
  description = "AMI ID used to launch the instance"
  value       = data.aws_ami.amazon_linux.id
}

output "ami_name" {
  description = "AMI name used to launch the instance"
  value       = data.aws_ami.amazon_linux.name
}

output "security_group_id" {
  description = "ID of the security group attached to the instance"
  value       = aws_security_group.ec2.id
}

output "website_url" {
  description = "URL to access the web server (available after instance is ready)"
  value       = "http://${aws_instance.ec2.public_ip}"
}
