# import json
# import logging
# import boto3



# def lambda_handler(event, context):
#     client = boto3.client('ssm')
#     result=client.get_parameter(Name="PLAIN_TEXT")['Parameter']['Value']
#     #return "Success"
#     print (result)
#     response = {'result': result}
#     return {
#         'statusCode': 200,
#         'body': response
        
#     }

# import json
# import logging
# import boto3

# logger = logging.getLogger()
# logger.setLevel(logging.INFO)
# e = ""
# def lambda_handler(event, context):
#     try:
#         # Your existing authentication logic here...
#         username = event.get('username')

#         # If authentication is successful, log it as INFO
#         logger.info(f"Authentication successful for user: {username}")

#         # Your existing code to handle successful authentication...

#         return {
#             'statusCode': 200,
#             'body': 'Authentication successful'
#         }
#     except Exception as e:
#         # If authentication fails, log it as ERROR
#         logger.error(f"Authentication failed for user: {event.get('username', 'Unknown')}. Error: {str(e)}")


        # Your existing code to handle failed authentication...

        # return {
        #     'statusCode': 401,
        #     'body': 'Authentication failed'
        # }

import json
import boto3
import datetime
import os
import logging

# Initialize the AWS SDK clients
ssm_client = boto3.client('ssm')

def lambda_handler(event, context):
    try:
        
        # Extract user information from the event
        claims = event['requestContext']['authorizer']['claims']
    
        # Retrieve the name and email attributes from the claims
        name = claims.get('name')
        email = claims.get('email')
        timestamp = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")

        # Retrieve the SSM parameter value
        response = ssm_client.get_parameter(Name='/res/hello', WithDecryption=False)
        hello_value = response['Parameter']['Value']

        # Create the response message
        response_message = f"{hello_value}, {name}, the current day and time is: {timestamp}"

        # Return the response
        return {
            'statusCode': 200,
            'body': json.dumps(response_message)
        }

    except Exception as e:
        # Log and return an error message if any error occurs
        print(e)
        return {
            'statusCode': 500,
            'body': json.dumps("An error occurred. Please try again later.")
        }
