resource "aws_vpc" "primary-vpc" {
    cidr_block = "10.0.0.0/16"
    enable_dns_hostnames = true
    tags = var.tags
}

module "custom-igw" {
  source  = "app.terraform.io/kevindemos/custom-igw/aws"
  version = "1.0.1"

  vpc_id = aws_vpc.primary-vpc.id
  tags = var.tags
}

resource "aws_subnet" "public-subnet" {
    vpc_id = aws_vpc.primary-vpc.id
    cidr_block = "10.0.1.0/24"
    availability_zone = "${var.aws_region}a"
    map_public_ip_on_launch = true
    tags = var.tags
    depends_on = [module.custom-igw]
}

resource "aws_route" "public-routes" {
    route_table_id = aws_vpc.primary-vpc.default_route_table_id
    destination_cidr_block = "0.0.0.0/0"
    gateway_id = module.custom-igw.id
}

resource "aws_route_table" "igw-route" {
    vpc_id = aws_vpc.primary-vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = module.custom-igw.id
    }
    tags = var.tags
}

resource "aws_route_table_association" "route-out" {
    route_table_id = aws_route_table.igw-route.id
    subnet_id      = aws_subnet.public-subnet.id
}
