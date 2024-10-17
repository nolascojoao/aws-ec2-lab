#!/bin/bash

# Stop execution on error
set -e

# Variables
REGION="us-east-2"  # Replace with your desired AWS region

# Task 2.1 - Retrieve the EC2 instance ID
echo "Retrieving the instance ID..."
INSTANCE_ID=$(aws ec2 describe-instances \
    --query "Reservations[0].Instances[0].InstanceId" \
    --output text \
    --region $REGION)

echo "Instance ID: $INSTANCE_ID"

# Task 2.1.1 - Retrieve the default Security Group ID (without VPC)
echo "Retrieving the default Security Group ID..."
SG_ID=$(aws ec2 describe-security-groups \
    --filters "Name=group-name,Values=default" \
    --query "SecurityGroups[0].GroupId" \
    --output text \
    --region $REGION)

echo "Default Security Group ID: $SG_ID"

# Task 2.2 - Add inbound rules to allow HTTP traffic on port 80
echo "Adding inbound rule to allow HTTP traffic to the security group $SG_ID..."
aws ec2 authorize-security-group-ingress \
    --group-id $SG_ID \
    --protocol tcp \
    --port 80 \
    --cidr 0.0.0.0/0 \
    --region $REGION

echo "HTTP access enabled on Security Group $SG_ID."

# Task 2.3 - Retrieve the public IP address of the instance
echo "Retrieving the public IP address of instance $INSTANCE_ID..."
PUBLIC_IP=$(aws ec2 describe-instances \
    --instance-ids $INSTANCE_ID \
    --query "Reservations[0].Instances[0].PublicIpAddress" \
    --output text \
    --region $REGION)

echo "Public IP address of the instance: $PUBLIC_IP"
