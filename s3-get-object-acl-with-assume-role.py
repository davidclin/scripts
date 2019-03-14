#!/usr/bin/env python
#
# Description: Retrieves list of all objects and group ACL settings.
#              To be used for cross accounts and not tri-na.
#
#              If an object's Group permission is set,
#
#              READ      means 'Read object' is enabled
#              READ_ACP  means 'Read object permissions' is enabled
#              WRITE_ACP means 'Write object permissions' is enabled
#
# Parameters :
#              account_profile    Human readable name of AWS account
#              account_id         AWS account ID
#              filename_tag       Prefix for output filename
#              bucket_name        Bucket name
#
# Invocation : nohup python <scriptname> &
#
# Output     :
#              List of all objects with group ACL settings (READ, READ_ACP, none)
#

import datetime
import logging
import boto3
from botocore.exceptions import ClientError

# ***************************  REQUIRED  **********************************
# Assign an account_profile description, one bucket_name, and
# one account_id before running the program.
#
# Note: Multiple profile descriptions, buckets and account id's are
# not supported.
#
account_profile = 'TARSAdmin'   # TARSAdmin
account_id = 276724084465
filename_tag = 'IE-1147'
bucket_name = 'robotobjects'
#bucket_name = 'facemagic2'
#
#account_profile='MaterialsAdmin' # MaterialsAdmin
#account_id=251589461219
#bucket_name = 'murat.test'
# *************************************************************************

# The calls to AWS STS AssumeRole must be signed with the access key ID
# and secret access key of an existing IAM user or by using existing temporary
# credentials such as those from antoher role. (You cannot call AssumeRole
# with the access key for the root account.) The credentials can be in
# environment variables or in a configuration file and will be discovered
# automatically by the boto3.client() function. For more information, see the
# Python SDK documentation:
# http://boto3.readthedocs.io/en/latest/reference/services/sts.html#client

# create an STS client object that represents a live connection to the
# STS service
sts_client = boto3.client('sts')

# Call the assume_role method of the STSConnection object and pass the role
# ARN and a role session name.
assumed_role_object=sts_client.assume_role(
    RoleArn="arn:aws:iam::" + str(account_id) + ":role/OrganizationAccountAccessRole",
    #RoleArn="arn:aws:iam::251589461219:role/OrganizationAccountAccessRole", # Example for MaterialsAdmin
    RoleSessionName="AssumeRoleSessionForS3ACLAudit"
)

# From the response that contains the assumed role, get the temporary
# credentials that can be used to make subsequent API calls
credentials=assumed_role_object['Credentials']

# Use the temporary credentials that AssumeRole returns to make a
# connection to Amazon S3
s3_resource=boto3.resource(
    's3',
    aws_access_key_id=credentials['AccessKeyId'],
    aws_secret_access_key=credentials['SecretAccessKey'],
    aws_session_token=credentials['SessionToken'],
)

s3_client = boto3.client(
    's3',
    aws_access_key_id=credentials['AccessKeyId'],
    aws_secret_access_key=credentials['SecretAccessKey'],
    aws_session_token=credentials['SessionToken'],
)


def get_object_acl(bucket_name, object_name):
    """Retrieve the access control list of an Amazon S3 object.

    :param bucket_name: string
    :param object_name: string
    :return: Dictionary defining the object's access control policy consisting
     of owner and grants. If error, return None.
    """

    # Retrieve the bucket ACL
    #s3 = boto3.client('s3')  # this was the original s3 resource without sts
    s3 = s3_client

    try:
        response = s3.get_object_acl(Bucket=bucket_name, Key=object_name)
    except ClientError as e:
        # AllAccessDisabled error == bucket not found
        logging.error(e)
        return None

    # Return both the Owner and Grants keys
    # The Owner and Grants settings together form the Access Control Policy.
    # The Grants alone form the Access Control List.
    return {'Owner': response['Owner'], 'Grants': response['Grants']}


def main():
    """Exercise get_object_acl()"""

    # Get current day time
    currentDT = datetime.datetime.now()

    # Set up logging
    logging.basicConfig(filename='example.log', filemode='w', level=logging.INFO,
                        format='%(levelname)s: %(message)s')

    # Open file
    f = open(str(filename_tag)+ '-' + str(account_profile) + '-' + str(account_id) + '-s3-acl-' + str(bucket_name) + '.md', "w")

    # Markdown banner header
    f.write('# ' + str(account_profile) + ' - ' + str(account_id) + '\r\n')
    f.write('<p>STARTED ' + str(currentDT) + '\r\n')
    f.write('<pre> \r\n')

    # Iterarate across all objects in bucket
    paginator = s3_client.get_paginator('list_objects_v2')
    result = paginator.paginate(Bucket=bucket_name)
    for page in result:
        if "Contents" in page:
            for key in page[ "Contents" ]:
                keyString = key[ "Key" ]
                object_name = key[ "Key" ]
                print object_name

                # Retrieve the object's current access control list
                acl = get_object_acl(bucket_name, object_name)
                if acl is None:
                    exit(-1)


                # Write object name to file/log
                f.write('---------------------------------\r\n')
                f.write(str(bucket_name) + '/' + str(object_name) + '\r\n')
                logging.info('------------------------------')
                logging.info({object_name})

                # Output the object ACL grantees and permissions
                for grantee in acl['Grants']:
                    # The grantee type determines the grantee_identifier
                    grantee_type = grantee['Grantee']['Type']
                    if grantee_type == 'CanonicalUser':
                        grantee_identifier = grantee['Grantee']['DisplayName']
                    elif grantee_type == 'AmazonCustomerByEmail':
                        grantee_identifier = grantee['Grantee']['EmailAddress']
                    elif grantee_type == 'Group':
                        grantee_identifier = grantee['Grantee']['URI']
                        f.write(grantee["Permission"] + '\r\n')
                        logging.info({grantee["Permission"]})
                    else:
                        grantee_identifier = 'Unknown'

    # Wrap up
    f.write('\r\n </pre> \r\n')
    currentDT = datetime.datetime.now()
    f.write('COMPLETED ' + str(currentDT))
    print 'S3 ACL audit completed! See ' + str(filename_tag) + '-' + str(account_profile) + '-' + str(account_id) + '-s3-acl-' + str(bucket_name) + '.md'

if __name__ == '__main__':
    main()
