provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "example" {
    #availability_zone = "us-east-1a"
    ami = "ami-9887c6e7" # centos 7
    instance_type = "t2.micro"
}
