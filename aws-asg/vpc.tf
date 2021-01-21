resource "aws_vpc" "demo" {
    cidr_block = "192.168.0.0/16"

    tags = {
      "Name" = "demo"
    }
}

resource "aws_subnet" "demo_subnet_1" {
    vpc_id = aws_vpc.demo.id
    cidr_block = "192.168.1.0/24"

    tags = {
      "Name" = "demo"
    }
}

resource "aws_internet_gateway" "demo" {
    vpc_id = aws_vpc.demo.id

    tags = {
        Name = "demo"
    }
}

resource "aws_route_table" "demo" {
    vpc_id = aws_vpc.demo.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.demo.id
    }
    tags = {
        Name = "demo"
    }
}

resource "aws_route_table_association" "demo" {
  subnet_id      = aws_subnet.demo_subnet_1.id
  route_table_id = aws_route_table.demo.id
}