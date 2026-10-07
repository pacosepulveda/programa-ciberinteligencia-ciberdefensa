resource "aws_security_group" "admin" {
  name = "telvora-admin"

  ingress {
    description = "SSH administration"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_s3_bucket" "evidence" {
  bucket = "telvora-m03-evidence-demo"
}

resource "aws_s3_bucket_public_access_block" "evidence" {
  bucket = aws_s3_bucket.evidence.id

  block_public_acls       = false
  ignore_public_acls      = false
  block_public_policy     = false
  restrict_public_buckets = false
}

resource "aws_ebs_volume" "data" {
  availability_zone = "eu-west-1a"
  size              = 20
  encrypted         = false
}

resource "aws_cloudwatch_log_group" "app" {
  name = "/telvora/m03/app"
}
