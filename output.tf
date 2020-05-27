output "id" {
    value = aws_vpc.primary-vpc.id
}

output "subnet_id" {
    value = aws_subnet.public-subnet.id
}