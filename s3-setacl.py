"""
Set bucket-owner-full-control on S3 objects.
Use S3 Batch Operations Completion Report to obtain list of failed objects then past under the key section below in quotations.
Use s3-setacl.sh to invoke this script.
"""

import boto3
from botocore.exceptions import ClientError, ParamValidationError

key=[
"directory/objectname-1",
"directory/objectname-2",
"etc"
]


if __name__ == "__main__":
    client = boto3.client('s3')
    bucketname = "miru-us-east-1"

try:
    for i in key:
        content = client.list_objects_v2(Bucket=bucketname,Prefix=i)
        if "Content" in str(content):
            print '"' + str(i) + '",'
except ClientError as e:
        print("Unexpected error: %s" % e)
