provider "aws" {
  region = "us-east-1"
}

resource "aws_db_instance" "example" {
    engine = "mysql"
    allocated_storage = 10
    instance_class = "db.t2.micro"
    name = "example_database"
    username = "admin"
    password = "${var.db_password}"
    # nye: ikke testet enda
    snapshot_identifier = "some-snap"
    skip_final_snapshot = true
}
