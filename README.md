# An SMS verification code API with Terraform and AWS

This repository contains a simple project that implements an SMS notification service using AWS Lambda, API Gateway, and DynamoDB.

## Overview

The SMS notification service allows users to send SMS messages to recipients. It relies on AWS Lambda an API Gateway for scaling.

## Architecture

- **AWS Lambda**: Handles incoming requests from the API Gateway and executes the business logic.
- **API Gateway**: Directs requests to the Lambda.
- **DynamoDB**: Stores information about SMS messages, including sender IDs, recipient phone numbers, and message bodies.


## Deployment

This project uses Terraform to configure and deploy the required infrastructure.

To package the Python script used for the Lambda itself, run `make-archive.sh`.

You can then use Terraform to provision and deploy the project. You will need AWS CLI installed and configured on your system.

## Troubleshooting

### Common Issues


- **Error**: "Invalid phone number".
  This error can occur when a user tries to send an SMS with an invalid or non-existent phone number. Confirm that the phone number is valid.
- **No SMS Received**: Either Disable the SMS Sandbox under SNS configuration, or add the desired phone number to the list of approved numbers.
