resource "aws_vpc" "main" {
# NAT Gateways: one per AZ using an Elastic IP
resource "aws_eip" "nat" {
for_each = aws_subnet.public
vpc = true
tags = { Name = "${var.project}-nat-eip-${each.key}" }
}


resource "aws_nat_gateway" "gw" {
for_each = aws_subnet.public
allocation_id = aws_eip.nat[each.key].id
subnet_id = each.value.id
tags = { Name = "${var.project}-nat-${each.key}" }
depends_on = [aws_internet_gateway.igw]
}


# Route Tables
resource "aws_route_table" "public" {
vpc_id = aws_vpc.main.id
route {
cidr_block = "0.0.0.0/0"
gateway_id = aws_internet_gateway.igw.id
}
tags = { Name = "${var.project}-public-rt" }
}


resource "aws_route_table_association" "public_assoc" {
for_each = aws_subnet.public
subnet_id = each.value.id
route_table_id = aws_route_table.public.id
}


# Private RTs (point to NAT)
resource "aws_route_table" "private" {
vpc_id = aws_vpc.main.id
tags = { Name = "${var.project}-private-rt" }
}


resource "aws_route" "private_nat" {
for_each = aws_nat_gateway.gw
route_table_id = aws_route_table.private.id
destination_cidr_block = "0.0.0.0/0"
nat_gateway_id = each.value.id
}


resource "aws_route_table_association" "private_assoc" {
for_each = aws_subnet.private
subnet_id = each.value.id
route_table_id = aws_route_table.private.id
}