import json
import boto3
import uuid

def lambda_handler(event, context):
    # Initialize the Step Functions client
    stepfunctions = boto3.client('stepfunctions')

    # Define the ARN of your state machine (replace with your ARN)
    state_machine_arn = 'arn:aws:states:us-west-1:525425830681:stateMachine:MyStateMachine-x5hxngr0b'

    # Extract relevant S3 event details
    try:
        record = event['Records'][0]  # Assuming there's at least one record
        bucket_name = record['s3']['bucket']['name']
        object_key = record['s3']['object']['key']
    except KeyError as e:
        print(f"Error parsing event: {e}")
        return {
            'statusCode': 400,
            'body': json.dumps('Invalid S3 event format')
        }

    # Define the input to your Step Function
    input_data = {
        "bucket": bucket_name,
        "key": object_key
    }

    # Start the execution of the Step Function
    try:
        response = stepfunctions.start_execution(
            stateMachineArn=state_machine_arn,
            name=f'Execution-{uuid.uuid4()}',  # Generate a unique execution name
            input=json.dumps(input_data)  # Pass the relevant data to the Step Function
        )
        print("Step Function invoked successfully:", response)
        return {
            'statusCode': 200,
            'body': json.dumps('Step Function invoked successfully!')
        }
    except Exception as e:
        print(f"Error invoking Step Function: {e}")
        return {
            'statusCode': 500,
            'body': json.dumps('Failed to invoke Step Function')
        }
