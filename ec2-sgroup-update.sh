#!/bin/bash

#--------
# AWS CLI
#--------
# The following AWS CLI configuration can used as reference
# if executing calls in a cross account.
# Use AWS_PROFILE=default if the AWS default IAM user credentials have EC2 permissions.
#
#
# ~/.aws/config
# [profile applied-intuition]
# region = us-east-1
# output = json
# role_arn = arn:aws:iam::123456789012:role/OrganizationAccountAccessRole

#----------
# VARIABLES
#----------
GROUP_ID=sg-0addb9821a30b72b3,sg-09ab31d5cefcd8022
CIDR=52.87.135.166/32,52.87.119.148/32,52.87.122.55/32,52.71.108.224/32,34.227.230.72/32,34.233.56.174/32
AWS_PROFILE=applied-intuition


#--------------------------------------
# Add security group rules to GROUP_IDs.
# Existing rules will stay intact.
#---------------------------------------
for groupid in $(echo $GROUP_ID | sed "s/,/ /g")
  do
    for cidr in $(echo $CIDR | sed "s/,/ /g")
    do
       # Configure http
       echo "Group-id:" $groupid "| CIDR:" $cidr " | Protocol: tcp  | Port: 80"
       aws ec2 authorize-security-group-ingress \
              --profile $AWS_PROFILE \
              --group-id $groupid \
              --protocol tcp \
              --port 80 \
              --cidr $cidr
       # Configure https
       echo "Group-id:" $groupid "| CIDR:" $cidr " | Protocol: tcp  | Port: 443"
       aws ec2 authorize-security-group-ingress  \
              --profile $AWS_PROFILE \
              --group-id $groupid \
              --protocol tcp \
              --port 443 \
              --cidr $cidr
       # Configure icmp destination unreachable fragramentation required, and DF flag set
       echo "Group-id:" $groupid "| CIDR:" $cidr " | Protocol: icmp | FromPort: 3 | ToPort 4"
       aws ec2 authorize-security-group-ingress \
              --profile $AWS_PROFILE \
              --group-id $groupid \
              --ip-permissions IpProtocol=icmp,FromPort=3,ToPort=4,IpRanges=[{CidrIp=$cidr}]
    done
  done
