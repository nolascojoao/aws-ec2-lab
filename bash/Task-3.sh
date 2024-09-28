#!/bin/bash

# Step 1: Enable Basic Monitoring for the specified EC2 instance
# Replace <instance-id> with your EC2 instance ID
INSTANCE_ID="<instance-id>"  # Specify the EC2 instance ID here

echo "Enabling basic monitoring for instance $INSTANCE_ID..."

aws ec2 monitor-instances --instance-ids $INSTANCE_ID

echo "Basic monitoring enabled for instance $INSTANCE_ID."

# Step 2: Check EC2 Monitoring Data
# Replace <start-time>, <end-time>, and <instance-id> with appropriate values
START_TIME="<start-time>"  # Specify the start time in ISO 8601 format (e.g., 2024-09-27T00:00:00Z)
END_TIME="<end-time>"      # Specify the end time in ISO 8601 format (e.g., 2024-09-27T23:59:59Z)

echo "Retrieving CPU utilization statistics for instance $INSTANCE_ID..."

aws cloudwatch get-metric-statistics \
    --namespace AWS/EC2 \
    --metric-name CPUUtilization \
    --start-time $START_TIME \
    --end-time $END_TIME \
    --period 300 \
    --statistics Average \
    --dimensions Name=InstanceId,Value=$INSTANCE_ID

echo "CPU utilization statistics retrieved for instance $INSTANCE_ID."
