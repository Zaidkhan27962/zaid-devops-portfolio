output "vpc_id" {
  value = aws_vpc.portfolio_vpc.id
}

output "public_subnet_id" {
  value = aws_subnet.public_subnet.id
}

output "internet_gateway_id" {
  value = aws_internet_gateway.portfolio_igw.id
}

output "route_table_id" {
  value = aws_route_table.public_rt.id
}

output "security_group_id" {
  value = aws_security_group.portfolio_sg.id
}

output "public_ip" {
  value = aws_instance.portfolio_ec2.public_ip
}

output "public_dns" {
  value = aws_instance.portfolio_ec2.public_dns
}

output "elastic_ip" {
  value = aws_eip.portfolio_eip.public_ip
}