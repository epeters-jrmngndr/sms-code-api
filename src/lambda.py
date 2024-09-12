#!/usr/bin/env python3
import json
import boto3
import os
from datetime import datetime

sns_client = boto3.client("sns")
dynamo_db_client = boto3.client("dynamodb")

TABLE_NAME = os.getenv("TABLE_NAME")
TTL = 15 * 60  # 15min


def lambda_handler(event, context):
    if "body" not in event.keys():
        return {"statusCode": 400, "body": json.dumps("No event provided")}

    try:
        body = json.loads(event["body"])
    except json.JSONDecodeError:
        return {"statusCode": 400, "body": json.dumps("Invalid JSON format")}

    first_name = body.get("first_name")
    last_name = body.get("last_name")
    code = body.get("code")
    phone_number = body.get("phone_number")
    current_time = int(datetime.now().timestamp())

    # Check if the phone number was messaged already
    try:
        response = dynamo_db_client.get_item(
            TableName=TABLE_NAME, Key={"phone_number": {"S": phone_number}}
        )
        item = response.get("Item")
        assert item
    except Exception as e:
        print(e)  # So it is recorded on CloudWatch
        return {
            "statusCode": 500,
            "body": json.dumps("Error retrieving item from DynamoDB"),
        }

    ttl = int(item["ttl"]["N"])

    if ttl > current_time:
        last_sent_date = datetime.fromtimestamp(int(item["timestamp"]["N"])).isoformat()
        return {
            "statusCode": 500,
            "body": json.dumps(f"Already messaged. Last sent date: {last_sent_date}"),
        }

    # Send SMS via SNS
    message = f"Hi {first_name} {last_name},\nyour code is {code}"
    try:
        sns_client.publish(Message=message, PhoneNumber=phone_number)
    except Exception as e:
        return {"statusCode": 500, "body": json.dumps("Error sending SMS via SNS")}

    # Store the phone number and timestamp in DynamoDB
    try:
        dynamo_db_client.put_item(
            TableName=TABLE_NAME,
            Item={
                "phone_number": {"S": phone_number},
                "timestamp": {"N": str(current_time)},
                "ttl": {"N": str(current_time + TTL)},
            },
        )
    except Exception as e:
        return {"statusCode": 500, "body": json.dumps("Error storing item in DynamoDB")}

    return {"statusCode": 200, "body": json.dumps("SMS sent successfully")}
