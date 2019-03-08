#!/bin/bash
# To concatenate output in order:
#   ls -1 *.txt | sort | while read fn ; do cat "$fn" >> output.md; done
# To concatenate by time:
#   ls -1 *.txt | while read fn ; do cat "$fn" >> output.md; done

ACCOUNTS=default,other-aws-cli-profile-names-go-here

# Loop through the ACCOUNTS array and output in markdown
for i in $(echo $ACCOUNTS | sed "s/,/ /g")
do
   echo 'Getting list of IAM users, S3 buckets, and IAM roles for account id' $i

   echo '# Account id:' $i > $i.txt
   echo '<pre>' >> $i.txt
   echo 'IAM UserNames' >> $i.txt
   aws iam list-users --profile $i | grep Users >> $i.txt

   echo 'S3 buckets' >> $i.txt
   aws s3api list-buckets --profile $i | grep Name >> $i.txt

   echo 'IAM roles' >> $i.txt
   aws iam list-roles --profile $i | grep RoleName >> $i.txt

   echo '</pre>' >> $i.txt
   echo '' >> $i.txt
done

echo 'done!'
