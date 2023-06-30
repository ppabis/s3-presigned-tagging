import boto3, os

s3 = boto3.client('s3')
bucket_name = os.environ['BUCKET_NAME']

HTML_TEMPLATE = """
<!DOCTYPE html>
<html>
    <head>
        <style>* {{font-family: Sans-Serif;}}</style>
        <title>Best photos</title>
    </head>
    <body>
        <h1>Best photos</h1>
        <ul>
            {list_items}
        </ul>
    </body>
</html>
"""

def get_list_items():
    response = s3.list_objects_v2(Bucket=bucket_name)
    items = response['Contents']
    list_items = ""
    for item in items:
        list_items += f"<li><a href=\"http://{bucket_name}.s3.amazonaws.com/{item['Key']}\">{item['Key']}</a></li>"
    return list_items

def lambda_handler(event, context):
    print("Hello from lambda")
    return {
        'headers': {
            'Content-Type': 'text/html'
        },
        'statusCode': 200,
        'body': HTML_TEMPLATE.format(list_items=get_list_items())
    }