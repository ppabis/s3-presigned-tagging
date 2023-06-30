import boto3, os

s3 = boto3.client('s3')
bucket_name = os.environ['BUCKET_NAME']

HTML_TEMPLATE = """
<!DOCTYPE html>
<html>
    <head>
        <style>* {{font-family: Sans-Serif;}}
        img {{ max-width:250px; }}</style>
        <title>Best photos</title>
    </head>
    <body>
        <h2>Upload photo</h2>
        <form action="" method="post">
            <label for="title">Title:</label>
            <input type="text" name="title">
            <input type="submit" value="Next">
        </form>
        <h1>Best photos</h1>
        <ul>
            {list_items}
        </ul>
    </body>
</html>
"""

def get_object_title_tag(key):
    # Will return either the tag "Title" or the key name if no tag is found
    response = s3.get_object_tagging(Bucket=bucket_name, Key=key)
    tags = response['TagSet']
    for tag in tags:
        if tag['Key'] == 'Title':
            return tag['Value']
    return key

def get_list_items():
    response = s3.list_objects_v2(Bucket=bucket_name)
    items = response['Contents']
    list_items = []
    for item in items:
        title = get_object_title_tag(item['Key'])
        list_items.append(f"""<li><div>
                          <h3>{title}</h3>
                          <a href=\"http://{bucket_name}.s3.amazonaws.com/{item['Key']}\">
                            <img src=\"http://{bucket_name}.s3.amazonaws.com/{item['Key']}\">
                          </a>
                        </div></li>""")
    return "\n".join(list_items)

def lambda_handler(event, context):
    return {
        'headers': {
            'Content-Type': 'text/html'
        },
        'statusCode': 200,
        'body': HTML_TEMPLATE.format(list_items=get_list_items())
    }