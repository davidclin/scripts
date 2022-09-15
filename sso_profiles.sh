#!/bin/bash

# `aws organizations list-accounts --query 'Accounts[*].[Id, Name]' --output text` > accounts.csv
AccountID=`aws organizations list-accounts --query 'Accounts[*].{ID:Id}'  | jq -r '.[].ID'`
for i in $AccountID
do
	  echo "[profile $i]" >> sso_pro
	    echo "sso_start_url = https://tri-sso.awsapps.com/start" >> sso_pro
	      echo "sso_region = us-east-1" >> sso_pro
	        echo "sso_role_name = AdministratorAccess" >> sso_pro
		  echo "sso_account_id = $i" >> sso_pro
		    echo "source_profile = default" >> sso_pro
		      echo " " >> sso_pro

done
