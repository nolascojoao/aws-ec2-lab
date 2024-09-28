#!/bin/bash

# Step 1: Retrieve the security group ID for the specified EC2 instance
# Replace <instance-id> with your EC2 instance ID
INSTANCE_ID="<instance-id>"  # Specify the EC2 instance ID here

echo "Retrieving security group ID for instance $INSTANCE_ID..."

SECURITY_GROUP_ID=$(aws ec2 describe-instances \
    --instance-ids $INSTANCE_ID \
    --query 'Reservations[*].Instances[*].SecurityGroups[*].GroupId' \
    --output text)  # Capture the Security Group ID

echo "Security Group ID: $SECURITY_GROUP_ID"

# Step 2: Add inbound rules to allow HTTP traffic to the security group
echo "Adding inbound rule to allow HTTP traffic (port 80) for Security Group $SECURITY_GROUP_ID..."

aws ec2 authorize-security-group-ingress \
    --group-id $SECURITY_GROUP_ID \
    --protocol tcp \
    --port 80 \
    --cidr 0.0.0.0/0  # Allow HTTP traffic from anywhere

echo "Inbound rule added for HTTP traffic."

# Step 3: Retrieve the public IPv4 address of the EC2 instance
echo "Retrieving public IPv4 address for instance $INSTANCE_ID..."

PUBLIC_IP=$(aws ec2 describe-instances \
    --instance-ids $INSTANCE_ID \
    --query 'Reservations[*].Instances[*].PublicIpAddress' \
    --output text)  # Capture the public IP address

echo "Public IPv4 Address: $PUBLIC_IP"
