"""
Set bucket-owner-full-control on S3 objects
"""

import boto3
from botocore.exceptions import ClientError, ParamValidationError

counter = 0

key=[

]


if __name__ == "__main__":
    client = boto3.client('s3')
    bucketname = "miru-us-east-1"

for i in key:
    try:
        counter += 1
        print "Count is: " + str(counter)
        print ""
        print "Key is: " + str(i)
        print ""
        print client.put_object_acl(Bucket=bucketname,Key=i,ACL='bucket-owner-full-control',)
        print ""
        print "------------------"
        print ""
    except ClientError as e:
        print("Unexpected error: %s" % e)
        print ""
        print "------------------"
