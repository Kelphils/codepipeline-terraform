output "vpc_id" {
  value       = aws_vpc.vpc.id
  description = "The ID of the VPC"
}

output "public_subnets_id" {
  value       = aws_subnet.public_subnet.*.id
  description = "The IDs of the public subnets"
}

output "private_subnets_id" {
  value       = aws_subnet.private_subnet.*.id
  description = "The IDs of the private subnets"
}
