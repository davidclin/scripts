#!/bin/bash
# To concatenate output in order:
#   rm output.md
#   ls -1 *.txt | sort | while read fn ; do cat "$fn" >> output.md; done
# To concatenate by time:
#   rm output.md
#   ls -1 *.txt | while read fn ; do cat "$fn" > output.md; done

ACCOUNTS=aws_profile_name_1,aws_profile_name_2 (provide list of aws profile names from your ~/.aws/config)

# Loop through the ACCOUNTS array
for i in $(echo $ACCOUNTS | sed "s/,/ /g")
do
   echo 'Getting list of IAM users, S3 buckets, and IAM roles for account id' $i

   echo '# Account Profile:' $i > $i.txt
   echo '<pre>' >> $i.txt

   echo 'Account ID' >> $i.txt
   aws sts get-caller-identity --query 'Account' --profile $i --output text >> $i.txt

   echo '' >> $i.txt

   echo 'IAM Users' >> $i.txt
   aws iam list-users --profile $i | grep UserName >> $i.txt

   echo '' >> $i.txt

   echo 'S3 buckets' >> $i.txt
   aws s3api list-buckets --profile $i | grep \"Name >> $i.txt

   echo '' >> $i.txt

   echo 'IAM roles' >> $i.txt
   aws iam list-roles --profile $i | grep RoleName >> $i.txt

   echo '' >> $i.txt

   echo 'Lambdas' >> $i.txt
   aws lambda list-functions --profile $i --region us-east-1 | grep FunctionName >> $i.txt

   echo '' >> $i.txt

   echo 'RDS Instances' >> $i.txt
   aws rds describe-db-instances --profile $i --region us-east-1 | grep DBName >> $i.txt

   echo '' >> $i.txt

   echo 'SQS' >> $i.txt
   aws sqs list-queues --profile $i --region us-east-1 | grep https  >> $i.txt

   echo '</pre>' >> $i.txt

done

echo 'Removing output.md'
rm output.md

echo 'Creating digest'
ls -1 *.txt | sort | while read fn ; do cat "$fn" >> output.md; done

echo 'Job completed!'
