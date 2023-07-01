import boto3, os
from redis import Redis

REDIS_HOST = os.environ['REDIS_HOST']

redis = Redis(host=REDIS_HOST, port=6379)
s3 = boto3.client('s3')

def get_from_redis(key):
    v = redis.get(key)
    if v is None:
        raise Exception(f"Key {key} not found in Redis")
    return v.decode('utf-8')

def update_tagging(record):
    key = record['s3']['object']['key']
    bucket = record['s3']['bucket']['name']
    title = get_from_redis(key)
    print(f"Key: {key}, Title: {title}")
    print(f"Updating tagging for {bucket}/{key}")
    s3.put_object_tagging(
        Bucket=bucket,
        Key=key,
        Tagging={
            'TagSet': [
                {
                    'Key': 'Title',
                    'Value': title
                }
            ]
        }
    )


# Handle S3 notification
def lambda_handler(event, context):
    print(event)
    for record in event['Records']:
        if 's3' in record:
            update_tagging(record)
        else:
            print(f"Unexpected record: {record}")
    return {
        'statusCode': 200,
        'body': 'OK'
    }
