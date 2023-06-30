import boto3, uuid, os
from urllib.parse import parse_qs

BUCKET_NAME = os.environ['BUCKET_NAME']
REDIRECT = os.environ['REDIRECT']

HTML_TEMPLATE = """
<!DOCTYPE html>
<html>
    <head>
        <style>* {{font-family: Sans-Serif;}}</style>
        <title>Upload {title}</title>
    </head>
    <body>
        <h2>Upload {title}</h2>
        <form action="{url}" method="post" enctype="multipart/form-data">
            {hidden_inputs}
            <label for="file">File:</label>
            <input type="file" id="file" name="file"> <br>
            <input type="submit" name="submit" value="Upload">
        </form>
    </body>
</html> 
"""

def create_upload_form(event):
    body = parse_qs(event['body'])
    title = body['title'][0].replace("<", "&lt;").replace(">", "&gt;").replace('"', "&quot;")
    uid = str(uuid.uuid4())
    print(f"Title: {title}, UUID: {uid}")
    
    s3 = boto3.client('s3')
    upload_form_fields = s3.generate_presigned_post(
        BUCKET_NAME,
        uid,
        Fields={"redirect": REDIRECT, "success_action_redirect": REDIRECT},
        Conditions=[
            ["starts-with", "$success_action_redirect", ""],
            ["starts-with", "$redirect", ""]
        ],
        ExpiresIn=600
    )
    print(upload_form_fields)
    hidden_inputs = [
        f"<input type=\"hidden\" name=\"{key}\" value=\"{value}\">"
        for (key, value) in upload_form_fields['fields'].items()
    ]
    return HTML_TEMPLATE.format(
        title=title,
        url=upload_form_fields['url'],
        hidden_inputs="\n".join(hidden_inputs)
    )
    

def lambda_handler(event, context):
    return {
        'statusCode': 201,
        'headers': {
            'Content-Type': 'text/html'
        },
        'body': create_upload_form(event)
    }