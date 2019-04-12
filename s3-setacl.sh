#!/usr/bin/bash

echo "============  START  =============" > result.txt

date >> result.txt
echo "" >> result.txt

python s3-setacl.py >> result.txt

date >> result.txt

echo "" >> result.txt
echo "Set ACL job completed!" >> result.txt
echo "" >> result.txt
echo "============  END  =============" >> result.txt
