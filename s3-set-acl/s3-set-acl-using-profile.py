"""
Set bucket-owner-full-control on S3 objects
"""

import boto3
from botocore.exceptions import ClientError, ParamValidationError

counter = 0

key=[
"folder1/test-1.txt",
"folder2/test-2.txt"
]


if __name__ == "__main__":
    # example using a profile named 'miru'
    miru = boto3.session.Session(profile_name='miru')
    miru_client = miru.client('s3')

    # example using default profile
    client = boto3.client('s3')

    # bucket name
    bucketname = "miru-us-east-1"
for i in key:

    try:
        counter += 1
        print "Count is: " + str(counter)
        print ""
        print "Key is: " + str(i)
        print ""

        # default profile
        # print client.put_object_acl(Bucket=bucketname,Key=i,ACL='bucket-owner-full-control',)

        # invoke api using different profile
        print miru_client.put_object_acl(Bucket=bucketname,Key=i,ACL='bucket-owner-full-control',)

        print ""
        print "------------------"
        print ""
    except ClientError as e:
        print("Unexpected error: %s" % e)
        print ""
        print "------------------"        
