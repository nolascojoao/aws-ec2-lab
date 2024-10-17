#!/bin/bash

# Stop execution on error
set -e

# Variables
REGION="us-east-2"  # Change to your preferred AWS region
NEW_INSTANCE_TYPE="t3.nano"  # Replace with your desired instance type
NEW_VOLUME_SIZE=10  # Replace with the new size for the EBS volume
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

# Task 4.1 - Stop Instance
echo "Stopping instance $INSTANCE_ID..."
aws ec2 stop-instances --instance-ids $INSTANCE_ID --region $REGION
echo "Waiting for instance to stop..."
aws ec2 wait instance-stopped --instance-ids $INSTANCE_ID --region $REGION
echo "Instance $INSTANCE_ID is now stopped."

# Task 4.2 - Modify the Instance Type
echo "Modifying instance type to $NEW_INSTANCE_TYPE for instance $INSTANCE_ID..."
aws ec2 modify-instance-attribute --instance-id $INSTANCE_ID --instance-type "{\"Value\": \"$NEW_INSTANCE_TYPE\"}" --region $REGION
echo "Instance type modified."

# Task 4.3 - Retrieve the EBS Volume ID
echo "Retrieving the EBS volume ID for instance $INSTANCE_ID..."
VOLUME_ID=$(aws ec2 describe-instances \
    --instance-ids $INSTANCE_ID \
    --query "Reservations[0].Instances[0].BlockDeviceMappings[0].Ebs.VolumeId" \
    --output text \
    --region $REGION)

if [ -z "$VOLUME_ID" ]; then
    echo "No EBS volume found for instance $INSTANCE_ID. Exiting..."
    exit 1
fi

echo "EBS Volume ID: $VOLUME_ID"

# Task 4.4 - Modify the EBS Volume Size
echo "Modifying EBS volume $VOLUME_ID to size $NEW_VOLUME_SIZE GB..."
aws ec2 modify-volume --volume-id $VOLUME_ID --size $NEW_VOLUME_SIZE --region $REGION
echo "Waiting for EBS volume modification to complete..."
aws ec2 wait volume-in-use --volume-ids $VOLUME_ID --region $REGION
echo "EBS volume $VOLUME_ID has been modified."

# Task 4.5 - Start Instance
echo "Starting instance $INSTANCE_ID..."
aws ec2 start-instances --instance-ids $INSTANCE_ID --region $REGION
echo "Waiting for instance to be in running state..."
aws ec2 wait instance-running --instance-ids $INSTANCE_ID --region $REGION
echo "Instance $INSTANCE_ID is now running."

# Retrieve and display updated instance information
echo "Retrieving updated instance details..."
aws ec2 describe-instances --instance-ids $INSTANCE_ID --region $REGION --output table

echo "Task completed."
