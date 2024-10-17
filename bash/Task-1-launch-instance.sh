#!/bin/bash

# Stop execution on error
set -e

# Variables
AMI_ID="ami-050cd642fd83388e4"  # Replace with your chosen AMI
INSTANCE_TYPE="t2.micro"        # Replace with your preferred instance type
USER_DATA_PATH="user-data.sh"   # Adjust path to your user-data file
REGION="us-east-2"              # Change to your desired AWS region

# Task 1.1 - Create the EC2 instance
echo "Launching EC2 instance..."
INSTANCE_ID=$(aws ec2 run-instances \
    --image-id $AMI_ID \
    --instance-type $INSTANCE_TYPE \
    --associate-public-ip-address \
    --user-data file://$USER_DATA_PATH \
    --instance-initiated-shutdown-behavior stop \
    --query "Instances[0].InstanceId" \
    --output text \
    --region $REGION)

echo "Instance launched with ID: $INSTANCE_ID"

# Task 1.2 - Enable Termination Protection
echo "Enabling termination protection for instance $INSTANCE_ID..."
aws ec2 modify-instance-attribute --instance-id $INSTANCE_ID --disable-api-termination --region $REGION

# Task 1.3 - Check Termination Protection Status
echo "Checking termination protection status for instance $INSTANCE_ID..."
TERMINATION_PROTECTION_STATUS=$(aws ec2 describe-instance-attribute \
    --instance-id $INSTANCE_ID \
    --attribute disableApiTermination \
    --query "DisableApiTermination.Value" \
    --output text \
    --region $REGION)

echo "Termination protection is set to: $TERMINATION_PROTECTION_STATUS"

echo "Script completed."