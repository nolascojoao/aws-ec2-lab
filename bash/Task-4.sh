#!/bin/bash

# Task 4: Scale and Modify Your EC2 Resources

# Replace <instance-id> and <volume-id> with your actual EC2 instance ID and EBS volume ID
INSTANCE_ID="<instance-id>"  # Specify the EC2 instance ID here
VOLUME_ID="<volume-id>"       # Specify the EBS volume ID here

# Step 4.1: Stop Instance
echo "Stopping instance $INSTANCE_ID..."
aws ec2 stop-instances --instance-ids $INSTANCE_ID
echo "Instance $INSTANCE_ID stopped."

# Step 4.2: Change the Instance Type
echo "Changing instance type for $INSTANCE_ID to t3.nano..."
aws ec2 modify-instance-attribute --instance-ids $INSTANCE_ID --instance-type "t3.nano"
echo "Instance type changed to t3.nano for instance $INSTANCE_ID."

# Step 4.3: Retrieve the EBS volume ID
echo "Retrieving EBS volume ID for instance $INSTANCE_ID..."
VOLUME_ID=$(aws ec2 describe-instances \
    --instance-ids $INSTANCE_ID \
    --query 'Reservations[*].Instances[*].BlockDeviceMappings[*].[Ebs.VolumeId]' \
    --output text)
echo "EBS Volume ID retrieved: $VOLUME_ID"

# Step 4.4: Modify the EBS volume
echo "Modifying EBS volume $VOLUME_ID to size 10 GB..."
aws ec2 modify-volume --volume-id $VOLUME_ID --size 10
echo "EBS volume $VOLUME_ID modified to size 10 GB."

# Step 4.5: Start Instance
echo "Starting instance $INSTANCE_ID..."
aws ec2 start-instances --instance-ids $INSTANCE_ID
echo "Instance $INSTANCE_ID started."
