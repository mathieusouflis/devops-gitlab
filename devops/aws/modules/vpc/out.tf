output "vpc_id" {
  description = "ID du VPC"
  value       = aws_vpc.vpc.id
}

output "public_subnets" {
  description = "Liste des subnets publics"
  value       = [aws_subnet.subnet_public["subnet_public_1"].id, aws_subnet.subnet_public["subnet_public_2"].id]
}

output "private_subnets" {
  description = "Liste des subnets privés"
  value       = [aws_subnet.subnet_private["subnet_private_1"].id, aws_subnet.subnet_private["subnet_private_2"].id]
}

output "vpc_zone_identifiers" {
  description = "Liste des zones d'available des sous-réseaux privés du VPC"
  value       = [aws_subnet.subnet_private["subnet_private_1"].id, aws_subnet.subnet_private["subnet_private_2"].id]
}
