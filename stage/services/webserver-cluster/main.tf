data "aws_availability_zones" "all" {}

provider "aws" {
  region = "us-east-1"
}

resource "aws_launch_configuration" "example" {
    image_id = "ami-9887c6e7" # centos 7
    instance_type = "t2.micro"
    security_groups = ["${aws_security_group.instance.id}"]

    # <<-EOF and EOF are Terraforms heredoc syntax for creating multiline strings
    user_data = <<-EOF
                #!/bin/bash

            sudo yum install -y https://centos7.iuscommunity.org/ius-release.rpm
            sudo yum update -y
            sudo yum install -y python36u python36u-libs python36u-devel python36u-pip python34-setuptools
            sudo easy_install-3.4 pip

            pip3 install --user flask

            echo "from flask import Flask
            app = Flask(__name__)

            @app.route('/')
            def hello_world():
            return 'Hello, World!'" | tee hello.py

            export FLASK_APP=hello.py
            flask run --host="${var.flask_host}"
                EOF

    lifecycle {
      create_before_destroy = true
    }

    /*tags {
      Name = "terraform-example"
    }*/
}

resource "aws_security_group" "instance" {
    name = "terraform-example-instance"

    ingress {
      from_port = "${var.server_port}"
      to_port = "${var.server_port}"
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }

    lifecycle{
      create_before_destroy = true
    }
}

resource "aws_autoscaling_group" "example" {
  launch_configuration = "${aws_launch_configuration.example.id}"
  #availability_zones = ["${data.aws_availability_zones.all.names}"]
  availability_zones = ["${data.aws_availability_zones.all.names[1]}"]

  # register each instance in the ELB when the instance is booting
  load_balancers = ["${aws_elb.example.name}"]
  health_check_type = "ELB"

  min_size = 2
  max_size = 10

  tag {
    key = "Name"
    value = "terraform-asg-example"
    propagate_at_launch = true
  }
}

# create elastic load balancer for distributing traffic across servers
resource "aws_elb" "example" {
  name = "terraform-asg-example"
  #availability_zones = ["${data.aws_availability_zones.all.names}"]
  availability_zones = ["${data.aws_availability_zones.all.names[1]}"]
  security_groups = ["${aws_security_group.elb.id}"]

  listener {
    instance_port = 80
    instance_protocol = "http"
    lb_port = "${var.server_port}"
    lb_protocol = "http"
  }

  #configure health_check for the ELB
  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 2
    timeout = 3
    target = "HTTP:${var.server_port}/"
    interval = 30
  }
}

# create security group to allow incoming requests on port 80
resource "aws_security_group" "elb" {
  name = "terraform-example-elb"

  ingress = {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # to allow health check requests
  egress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
