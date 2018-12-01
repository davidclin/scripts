"""
Delete analytics configurations for an S3 bucket.

- AWS CLI: aws s3api delete-bucket-analytics-configuration --bucket us-west-2.nag --id full1
"""

import boto3

s3 = boto3.resource('s3')
client = boto3.client('s3')
id = "report"

for bucket in s3.buckets.all():

    filter_id = client.list_bucket_analytics_configurations(Bucket=bucket.name)

    if 'AnalyticsConfigurationList' in filter_id:
        print "Bucket name and filter_id type is: " , bucket.name , type(filter_id)
        print filter_id['AnalyticsConfigurationList'][0]['Id']

        if id in filter_id['AnalyticsConfigurationList'][0]['Id']:
            print "*** foo IS in this bucket and was deleted ***"
            analytics_config = client.delete_bucket_analytics_configuration(Bucket=bucket.name, Id=id)
