output "webserver_instance_ids" {
  description = "IDs of EC2 instances"
  value       = aws_autoscaling_group.webserver_group.id
}
output "asg_name" {
  description = "Name of autoscaling group"
  value       = aws_autoscaling_group.webserver_group.name
}
