
resource "aws_vpc" "vpc" {
  cidr_block           = "${var.vpc-cidr}"
  enable_dns_hostnames = true
}

resource "aws_subnet" "public-subnet" {
  vpc_id            = "${aws_vpc.vpc.id}"
  cidr_block        = "${var.subnet-cidr-public}"
  availability_zone = "${var.region}a"
}

resource "aws_subnet" "public-subnet2" {
  vpc_id            = "${aws_vpc.vpc.id}"
  cidr_block        = "${var.subnet-cidr-public2}"
  availability_zone = "${var.region}b"
}

resource "aws_route_table" "public-subnet-route-table" {
  vpc_id = "${aws_vpc.vpc.id}"
}

resource "aws_route_table" "public-subnet-route-table2" {
  vpc_id = "${aws_vpc.vpc.id}"
}

resource "aws_internet_gateway" "igw" {
  vpc_id = "${aws_vpc.vpc.id}"
}

resource "aws_route" "public-subnet-route" {
  destination_cidr_block  = "0.0.0.0/0"
  gateway_id              = "${aws_internet_gateway.igw.id}"
  route_table_id          = "${aws_route_table.public-subnet-route-table.id}"
}

resource "aws_route" "public-subnet-route2" {
  destination_cidr_block  = "0.0.0.0/0"
  gateway_id              = "${aws_internet_gateway.igw.id}"
  route_table_id          = "${aws_route_table.public-subnet-route-table2.id}"
}

resource "aws_route_table_association" "public-subnet-route-table-association" {
  subnet_id      = "${aws_subnet.public-subnet.id}"
  route_table_id = "${aws_route_table.public-subnet-route-table.id}"
}

resource "aws_route_table_association" "public-subnet-route-table-association2" {
  subnet_id      = "${aws_subnet.public-subnet2.id}"
  route_table_id = "${aws_route_table.public-subnet-route-table2.id}"
}
