provider "aws" {
  region = "${var.region}"
}

resource "aws_key_pair" "web" {
  public_key = "${file(pathexpand(var.public_key))}"
}


#resource "aws_instance" "web-instance" {
#  ami           = "${var.ami_id}"
#  instance_type = "${var.ami_name}"
#  vpc_security_group_ids      = [ "${aws_security_group.web-instance-security-group.id}" ]
#  subnet_id                   = "${aws_subnet.public-subnet.id}"
#  associate_public_ip_address = true
#  key_name                    = "${aws_key_pair.web.key_name}"
#  tags                        = {Name = "web-instance1"}
#  user_data                   = <<EOF
#    #!/bin/sh
#    sudo amazon-linux-extras install nginx1 -y
#    sudo service nginx start
#    EOF
#}
#
#
#resource "aws_instance" "web-instance2" {
#  ami           = "${var.ami_id}"
#  instance_type = "${var.ami_name}"
#  vpc_security_group_ids      = [ "${aws_security_group.web-instance-security-group.id}" ]
#  subnet_id                   = "${aws_subnet.public-subnet2.id}"
#  associate_public_ip_address = true
#  key_name                    = "${aws_key_pair.web.key_name}"
#  tags                        = {Name = "web-instance2"}
#  user_data                   = <<EOF
#    #!/bin/sh
#    sudo amazon-linux-extras install nginx1 -y
#    sudo service nginx start
#    EOF
#}


resource "aws_autoscaling_group" "web_asg" {
  name = "web-asg"
  max_size = "2"
  min_size = "2"
  health_check_grace_period = "300"
  health_check_type = "ELB"
  launch_configuration = "${aws_launch_configuration.web-lci.id}"
  load_balancers = ["${aws_elb.web_elb.name}"]
  vpc_zone_identifier = [ "${aws_subnet.public-subnet.id}", "${aws_subnet.public-subnet2.id}" ]
  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_launch_configuration" "web-lci" {
  image_id                    = "${var.ami_id}"
  instance_type               = "${var.ami_name}"
  security_groups              = [ "${aws_security_group.web-instance-security-group.id}" ]
  associate_public_ip_address = true
  key_name                    = "${aws_key_pair.web.key_name}"
  user_data                   = <<EOF
    #!/bin/sh
    sudo amazon-linux-extras install nginx1 -y
    sudo service nginx start
    EOF
}

resource "aws_elb" "web_elb" {
  name            = "web-elb1"
  security_groups = ["${aws_security_group.elb-security-group.id}"]
  #instances       = ["${aws_launch_configuration.web-lci.id}", "${aws_instance.web-instance2.id}"]
  subnets         = [ "${aws_subnet.public-subnet.id}", "${aws_subnet.public-subnet2.id}" ]

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
  value = [ "${aws_elb.web_elb.dns_name}" ]
}

