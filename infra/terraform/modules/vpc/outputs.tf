output "vpc_id" {
  value = aws_vpc.gpu_e2e
}

output "private_subnet_ids" {
  value = [aws_subnet.private_a.id]
}
