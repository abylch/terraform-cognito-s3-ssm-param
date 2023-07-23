# sudo zip lambda_function.zip lambda_function.py
import json
import boto3
import datetime
import os
import logging

# Initialize the AWS SDK clients
ssm_client = boto3.client('ssm')

# DynamoDB table name
table_name = 'user-table-01'

# S3 bucket name
bucket_name = 'bucket-commit-01'

def lambda_handler(event, context):
    try:
        
        # Extract user information from the event
        claims = event['requestContext']['authorizer']['claims']
    
        # Retrieve the name and email attributes from the claims
        name = claims.get('name')
        email = claims.get('email')
        timestamp = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")

        # Write user information to DynamoDB
        dynamodb_resource = boto3.resource("dynamodb")
        table = dynamodb_resource.Table(table_name)
        #inserting values into table
        response = table.put_item(
        Item={
                "username": name,
                "timestamp": timestamp,
            }
        )

        # Prepare the file content for the S# bucket
        file_content = f"Hello {name}, the current time is: {timestamp}"
        # Upload the file to the S3 bucket
        s3_client = boto3.client('s3')
        new_name = name.replace(" ", "_")
        file_name = f"{new_name}.txt"
        s3_client.put_object(Bucket=bucket_name, Key=file_name, Body=file_content)

        # logger
        logger = logging.getLogger()
        logger.setLevel(logging.INFO)
    
        # If authentication is successful, log it as INFO
        logger.info(f"Authentication successful for user: {name}")
    

        # Retrieve the SSM parameter value
        response = ssm_client.get_parameter(Name='/res/hello', WithDecryption=False)
        hello_value = response['Parameter']['Value']

        # Create the response message
        response_message = f"{hello_value}, {name}, the current day and time is: {timestamp}, dynamoDB updated, 'file_name': {file_name}, login event in log cloudwatch and ssm param retrieve"

        # Return the response
        return {
            'statusCode': 200,
            'headers' : {
                "Access-Control-Allow-Headers": 'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token',
                "Access-Control-Allow-Methods": '*',
                "Access-Control-Allow-Origin": '*'
                         },
            'body': json.dumps(response_message)
        }

    except Exception as e:
        # Log and return an error message if any error occurs
        print(e)
        return {
            'statusCode': 500,
            'headers' : {
                "Access-Control-Allow-Headers": 'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token',
                "Access-Control-Allow-Methods": '*',
                "Access-Control-Allow-Origin": '*'
                         },
            'body': json.dumps("An error occurred. Please try again later.")
        }
