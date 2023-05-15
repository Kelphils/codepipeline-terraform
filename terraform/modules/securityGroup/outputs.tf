output "docker_app_sg_id" {
  value       = aws_security_group.docker_instance_sg.id
  description = "The ID of the security group"
}
