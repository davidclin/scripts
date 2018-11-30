"""

Create analytics configurations for an S3 bucket.

Boto3 Doc: https://boto3.amazonaws.com/v1/documentation/api/latest/reference/services/s3.html#S3.Client.put_bucket_analytics_configuration

AWS CLI: aws s3api put-bucket-analytics-configuration --bucket us-west-2.nag --analytics-configuration '{"Id": "full1","StorageClassAnalysis": {}}' --id "report"

"""

import boto3

config = {"Id": "report","StorageClassAnalysis": {'DataExport': {'OutputSchemaVersion': 'V_1','Destination': {'S3BucketDestination': {'Format': 'CSV','Bucket': 'ar
n:aws:s3:::david-lin-ctr-test','Prefix':"foo"}}}}}

if __name__ == "__main__":
        client = boto3.client('s3')
        bucketname = "david-lin-ctr-analytics"
        analytics_config = client.put_bucket_analytics_configuration(Bucket=bucketname, Id="report", AnalyticsConfiguration=config)
#        analytics_destination_bucket = client.put_bucket_analytics_configuration(Bucket=bucketname, Id="report", StorageClassAnalysis.DataExport.Destination.S3Buc
ketDestination.Bucket=bucketname)
        print analytics_config
