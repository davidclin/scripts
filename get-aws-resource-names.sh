#!/bin/bash

ACCOUNTS=default

# Loop through the ACCOUNTS array
for i in $(echo $ACCOUNTS | sed "s/,/ /g")
do
   echo 'Getting list of IAM users, S3 buckets, and IAM roles for account id' $i
   echo 'Account id:' $i > $i.txt
   echo 'IAM UserNames' >> $i.txt
   aws iam list-users --profile $i | grep Users >> $i.txt

   echo 'S3 buckets' >> $i.txt
   aws s3api list-buckets --profile $i | grep Name >> $i.txt

   echo 'IAM roles' >> $i.txt
   aws iam list-roles --profile $i | grep RoleName >> $i.txt
done

echo 'done!'
