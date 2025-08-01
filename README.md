EC2 Instance Toggle Automation using Terraform and AWS Lambda
This project automates the process of starting and stopping two EC2 instances on AWS so that only one instance runs at a time. It helps save cost and demonstrates how to use infrastructure as code and serverless automation.

The infrastructure is created using Terraform. A Python-based AWS Lambda function is used to check the state of the two EC2 instances and toggle them. If both instances are stopped, it starts one. If both are running, it stops one. If only one is running, it switches the state. The Lambda function runs every minute using an EventBridge scheduler.

What this project includes:

Two EC2 instances created via Terraform

An AWS Lambda function written in Python

An IAM role that allows Lambda to control EC2

A CloudWatch EventBridge rule to trigger the Lambda every 1 minute

Why I built this:
This was a learning project to practice writing infrastructure code with Terraform and automate EC2 actions using Lambda. I also wanted to understand how to schedule Lambda execution and manage IAM permissions securely.

Technologies used:

Terraform

AWS EC2

AWS Lambda (Python 3.12)

EventBridge for scheduling

IAM roles and policies

CloudWatch Logs

How to use:

Clone this repository to your local machine

Make sure you have AWS CLI configured with aws configure

Create a ZIP file of the lambda function using the command:
zip lambda_function_payload.zip lambda_function.py

Run terraform init to set up the provider

Run terraform apply to create the infrastructure

Go to the AWS console to verify that EC2 instances are created

Check CloudWatch logs to see the Lambda function executing every minute

Watch the EC2 instances alternate between running and stopped

To clean up everything and avoid ongoing charges, run terraform destroy

This project helped me understand how to combine infrastructure provisioning with serverless automation. It’s a simple but powerful pattern for managing AWS resources more efficiently.

Author: Karthick Krishnasaisha
