#!/bin/bash

# Task 5: Manage Termination Protection and Cleanup

# Replace <instance-id> with your actual EC2 instance ID
INSTANCE_ID="<instance-id>"  # Specify the EC2 instance ID here

# Step 5.1: Test Termination Protection
echo "Attempting to terminate instance $INSTANCE_ID (should fail if termination protection is enabled)..."
aws ec2 terminate-instances --instance-ids $INSTANCE_ID
echo "Termination command issued for instance $INSTANCE_ID."

# Step 5.2: Disable Termination Protection
echo "Disabling termination protection for instance $INSTANCE_ID..."
aws ec2 modify-instance-attribute --instance-ids $INSTANCE_ID --no-disable-api-termination
echo "Termination protection disabled for instance $INSTANCE_ID."

# Step 5.3: Terminate the Instance
echo "Terminating instance $INSTANCE_ID..."
aws ec2 terminate-instances --instance-ids $INSTANCE_ID
echo "Termination command issued for instance $INSTANCE_ID."

# Step 5.4: Verify the Instance Status
echo "Verifying the status of instance $INSTANCE_ID..."
aws ec2 describe-instances \
    --instance-ids $INSTANCE_ID \
    --query 'Reservations[*].Instances[*].[InstanceId,State.Name]' \
    --output table
