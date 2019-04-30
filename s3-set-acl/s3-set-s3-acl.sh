#!/usr/bin/bash

echo "============  START  =============" > result.txt

date >> result.txt
echo "" >> result.txt

python s3-set-acl.py >> result.txt

date >> result.txt

echo "" >> result.txt
echo "Set ACL job completed!" >> result.txt
echo "" >> result.txt
echo "============  END  =============" >> result.txt
