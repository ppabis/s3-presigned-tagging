
def lambda_handler(event, context):
    print("Hello from lambda")
    return {
        'headers': {
            'Content-Type': 'text/html'
        },
        'statusCode': 200,
        'body': 'Hello from Lambda!'
    }