
def lambda_handler(event, context):
    print("Hello from lambda")
    return {
        'statusCode': 200,
        'body': 'Hello from Lambda!'
    }