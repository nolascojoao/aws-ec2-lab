#!/bin/bash

# Stop execution on error
set -e

# Variables
REGION="us-east-2"  # Replace with your desired AWS region
START_TIME=$(date -u -d '15 minutes ago' +'%Y-%m-%dT%H:%M:%SZ')  # Set the start time (15 minutes ago)
END_TIME=$(date -u +'%Y-%m-%dT%H:%M:%SZ')  # Set the end time to current time

# Task 3.1 - Enable Basic Monitoring with CloudWatch
echo "Retrieving an instance ID in 'running' state..."
INSTANCE_ID=$(aws ec2 describe-instances \
    --filters "Name=instance-state-name,Values=running" \
    --query "Reservations[0].Instances[0].InstanceId" \
    --output text \
    --region $REGION)

if [ "$INSTANCE_ID" == "None" ]; then
    echo "No running instances found."
    exit 1
fi

echo "Running Instance ID: $INSTANCE_ID"

# Enabling basic monitoring for the selected running instance
echo "Enabling basic monitoring for instance $INSTANCE_ID..."
aws ec2 monitor-instances --instance-ids $INSTANCE_ID --region $REGION
echo "Basic monitoring enabled."

# Task 3.2 - Retrieve CPU Utilization data from CloudWatch
echo "Retrieving CPU utilization data for instance $INSTANCE_ID from $START_TIME to $END_TIME..."

aws cloudwatch get-metric-statistics \
    --namespace AWS/EC2 \
    --metric-name CPUUtilization \
    --start-time $START_TIME \
    --end-time $END_TIME \
    --period 300 \
    --statistics Average \
    --dimensions Name=InstanceId,Value=$INSTANCE_ID \
    --region $REGION

echo "CPU utilization data retrieved."
