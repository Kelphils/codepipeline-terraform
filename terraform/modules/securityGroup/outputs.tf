output "java_app_sg_id" {
  value       = aws_security_group.java_instance_sg.id
  description = "The ID of the security group"
}
