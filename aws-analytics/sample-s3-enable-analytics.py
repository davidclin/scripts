import boto3
# get list of all buckets
s3 = boto3.resource('s3')

# enable analytics with filter named 'test'
config = {"Id": "foo","StorageClassAnalysis": {}}
client = boto3.client('s3')
bucketname = "david-lin-ctr-analytics" 
analytics_config = client.put_bucket_analytics_configuration(Bucket=bucketname, Id="foo", AnalyticsConfiguration=config)
print analytics_config
