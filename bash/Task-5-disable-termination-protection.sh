#!/bin/bash

# Stop execution on error
set -e

# Variables
REGION="us-east-2"  # Change to your preferred AWS region
INSTANCE_ID=$(aws ec2 describe-instances \
    --filters "Name=instance-state-name,Values=running" \
    --query "Reservations[0].Instances[0].InstanceId" \
    --output text \
    --region $REGION)

if [ "$INSTANCE_ID" == "None" ]; then
    echo "No running instances found. Exiting..."
    exit 1
fi

echo "Running Instance ID: $INSTANCE_ID"

# Task 5.1 - Disable Termination Protection
echo "Disabling termination protection for instance $INSTANCE_ID..."
aws ec2 modify-instance-attribute --instance-id $INSTANCE_ID --no-disable-api-termination --region $REGION
echo "Termination protection disabled."

# Task 5.2 - Terminate the Instance
echo "Terminating instance $INSTANCE_ID..."
aws ec2 terminate-instances --instance-ids $INSTANCE_ID --region $REGION
echo "Instance $INSTANCE_ID is being terminated."

# Task 5.3 - Verify the Instance Status
echo "Verifying the status of instance $INSTANCE_ID..."
aws ec2 describe-instances \
    --instance-ids $INSTANCE_ID \
    --query 'Reservations[*].Instances[*].[InstanceId,State.Name]' \
    --output table --region $REGION

echo "Task completed."
