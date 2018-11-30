
# Example of script that executes a command within a virtual environment.
# Cloud Custodian CLI is used here as an example.

#!/bin/bash
# example.sh
cd /home/ubuntu/cloudcustodian
source c7n_mailer/bin/activate
sudo -u ubuntu /home/ubuntu/c7n_mailer/bin/custodian run -s output /home/ubuntu/cloudcustodian/policies/s3-service-limit-audit.yml --region us-east-1

# Accompanying cron job
# crontab -e
* 3 * * * /home/ubuntu/example.sh 

