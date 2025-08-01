
provider "aws" {
  region = "us-east-1" # Change if needed
}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}


resource "aws_instance" "instance1" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t2.micro"

  tags = {
    Name = "Toggle-Instance-1"
  }
}

resource "aws_instance" "instance2" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t2.micro"

  tags = {
    Name = "Toggle-Instance-2"
  }
}

resource "aws_iam_role" "lambda_exec_role" {
  name = "lambda-ec2-toggle-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "lambda_policy" {
  name = "ec2-start-stop"
  role = aws_iam_role.lambda_exec_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ec2:StartInstances",
          "ec2:StopInstances",
          "ec2:DescribeInstanceStatus"
        ],
        Resource = "*"
      },
      {
        Effect   = "Allow",
        Action   = "logs:*",
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

resource "aws_lambda_function" "ec2_toggle" {
  filename         = "lambda_function_payload.zip"
  function_name    = "toggleEC2Instances"
  role             = aws_iam_role.lambda_exec_role.arn
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.12"
  source_code_hash = filebase64sha256("lambda_function_payload.zip")
  timeout          = 30
  memory_size      = 128

  environment {
    variables = {
      INSTANCE1_ID = aws_instance.instance1.id
      INSTANCE2_ID = aws_instance.instance2.id
    }
  }

  depends_on = [aws_iam_role_policy.lambda_policy]
}

resource "aws_cloudwatch_event_rule" "every_minute" {
  name                = "run-ec2-toggle-every-minute"
  schedule_expression = "rate(1 minute)"
}

resource "aws_cloudwatch_event_target" "lambda_target" {
  rule      = aws_cloudwatch_event_rule.every_minute.name
  target_id = "ec2LambdaTarget"
  arn       = aws_lambda_function.ec2_toggle.arn
}

resource "aws_lambda_permission" "allow_cloudwatch" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.ec2_toggle.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.every_minute.arn
}
