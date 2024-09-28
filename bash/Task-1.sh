#!/bin/bash

# Step 1: Create an EC2 instance using the specified AMI and instance type
# Replace <ami-0ebfd941bbafe70c6> with your chosen AMI ID
# Replace t2.micro with your preferred instance type if needed

INSTANCE_ID=$(aws ec2 run-instances \
    --image-id ami-0ebfd941bbafe70c6 \  # Specify the AMI ID
    --instance-type t2.micro \          # Specify the instance type
    --associate-public-ip-address \     # Associate a public IP address
    --user-data file://user-data.sh \   # Specify the user data script to configure the instance at launch
    --instance-initiated-shutdown-behavior stop \ # Set instance shutdown behavior to stop
    --query "Instances[0].InstanceId" \ # Capture the instance ID
    --output text)  # Output instance ID to a variable

echo "EC2 instance created with ID: $INSTANCE_ID"

# Step 2: Enable termination protection for the instance
aws ec2 modify-instance-attribute --instance-ids $INSTANCE_ID --disable-api-termination
echo "Termination protection enabled for instance $INSTANCE_ID"

# Step 3: Check if termination protection is enabled
aws ec2 describe-instance-attribute \
    --instance-ids $INSTANCE_ID \
    --attribute disableApiTermination
echo "Termination protection status checked for instance $INSTANCE_ID"
