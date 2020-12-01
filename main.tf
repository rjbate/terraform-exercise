provider "aws" {
  region = "${var.region}"
}

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

resource "aws_key_pair" "web" {
  public_key = "${file(pathexpand(var.public_key))}"
}


resource "aws_instance" "web-instance" {
  ami           = "ami-09558250a3419e7d0"
  instance_type = "t2.micro"
  vpc_security_group_ids      = [ "${aws_security_group.web-instance-security-group.id}" ]
  subnet_id                   = "${aws_subnet.public-subnet.id}"
  associate_public_ip_address = true
  key_name                    = "${aws_key_pair.web.key_name}"
  user_data                   = <<EOF
#!/bin/sh
sudo amazon-linux-extras install nginx1 -y
sudo service nginx start
EOF
}

resource "aws_instance" "web-instance2" {
  ami           = "ami-09558250a3419e7d0"
  instance_type = "t2.micro"
  vpc_security_group_ids      = [ "${aws_security_group.web-instance-security-group.id}" ]
  subnet_id                   = "${aws_subnet.public-subnet2.id}"
  associate_public_ip_address = true
  key_name                    = "${aws_key_pair.web.key_name}"
  user_data                   = <<EOF
    #!/bin/sh
    sudo amazon-linux-extras install nginx1 -y
    sudo service nginx start
    EOF
}


resource "aws_security_group" "web-instance-security-group" {
  vpc_id      = "${aws_vpc.vpc.id}"

  ingress = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


## Security Group for ELB
resource "aws_security_group" "elb" {
  name = "elb"
  vpc_id = "${aws_vpc.vpc.id}"
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
### Creating ELB
resource "aws_elb" "web_elb" {
  name = "web-elb1"
  security_groups = ["${aws_security_group.elb.id}"]
  instances = ["${aws_instance.web-instance.id}", "${aws_instance.web-instance2.id}"]
  subnets = [ "${aws_subnet.public-subnet.id}", "${aws_subnet.public-subnet2.id}" ]

  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 2
    timeout = 3
    interval = 30
    target = "HTTP:80/"
  }

  listener {
    lb_port = 80
    lb_protocol = "http"
    instance_port = "80"
    instance_protocol = "http"
  }
}

output "web_domain" {
  value = ["${aws_instance.web-instance.public_dns}", "${aws_instance.web-instance2.public_dns}", "${aws_elb.web_elb.dns_name}" ]
}

