resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name        = "coderhouse-${var.environment}-vpc"
    Environment = var.environment
    Project     = "coderhouse-data-engineering"
  }
}
data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_subnet" "private" {
  count = 2

  vpc_id = aws_vpc.main.id

  cidr_block = cidrsubnet(
    var.vpc_cidr,
    8,
    count.index + 1
  )

  availability_zone = data.aws_availability_zones.available.names[count.index]

  map_public_ip_on_launch = false

  tags = {
    Name        = "coderhouse-${var.environment}-private-${count.index + 1}"
    Environment = var.environment
    Project     = "coderhouse-data-engineering"
  }
}
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name        = "coderhouse-${var.environment}-private-rt"
    Environment = var.environment
    Project     = "coderhouse-data-engineering"
  }
}

resource "aws_route_table_association" "private" {
  count = 2

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}
data "aws_region" "current" {}

resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${data.aws_region.current.region}.s3"
  vpc_endpoint_type = "Gateway"

  route_table_ids = [
    aws_route_table.private.id
  ]

  tags = {
    Name        = "coderhouse-${var.environment}-s3-endpoint"
    Environment = var.environment
    Project     = "coderhouse-data-engineering"
  }
}