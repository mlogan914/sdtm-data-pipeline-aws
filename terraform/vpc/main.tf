# =============================================================
# VPC Configuration
# This provisions VPC and subnets for the ECS containers
# ============================================================

# Define data source to fetch available availability zones
data "aws_availability_zones" "available" {
    state = "available"
}

# Create VPC
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "main-vpc"
  }
}

# ----------------------------------------
# Create Subnets
# ----------------------------------------

# Private Subnet
resource "aws_subnet" "private" {
  count                   = 2
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.${count.index}.0/24" # Unique CIDR for each subnet
  map_public_ip_on_launch = false  # No public IPs
  availability_zone       = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "private-subnet-${count.index}"
  }
}
# -------------------------------------------------------------------
# Create NAT Gateway + a Public Subnet 
# This is so ECS tasks (in a private subnet) can pull images from ECR
# -------------------------------------------------------------------

# Public Subnet
resource "aws_subnet" "public" {
  count                   = 1
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.100.0/24"  # Separate range from private subnets
  map_public_ip_on_launch = true  # Public subnet needs public IPs
  availability_zone       = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "public-subnet"
  }
}

# ---------------------------------------------------------------
# Internet Gateway
# The NAT Gateway needs an Internet Gateway so it can reach ECR
# ---------------------------------------------------------------
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main-igw"
  }
}

# NAT Gateway
resource "aws_eip" "nat_eip" {
  domain = "vpc"
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public[0].id

  tags = {
    Name = "main-nat"
  }
}

#-------------------------------------------------------------------
# Route Table
# Tell private subnets to use the NAT Gateway for outbound traffic
#-------------------------------------------------------------------

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  tags = {
    Name = "private-route-table"
  }
}

# Associate Private Subnets with this Route Table
resource "aws_route_table_association" "private" {
  count          = 2
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}


