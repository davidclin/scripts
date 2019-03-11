#!/bin/bash
# To concatenate output in order:
#   rm output.md
#   ls -1 *.txt | sort | while read fn ; do cat "$fn" >> output.md; done
# To concatenate by time:
#   rm output.md
#   ls -1 *.txt | while read fn ; do cat "$fn" > output.md; done

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

   echo '</pre>' >> $i.txt

done

echo 'done!'
