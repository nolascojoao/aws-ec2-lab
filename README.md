# AWS EC2 Introduction Lab

<div align="center">
  <img src="screenshot/Cloud Architecture.png" width="280"/>
</div>

## Overview

This lab provides a guide to:

- **Launching an EC2 Instance**: Create an Amazon EC2 instance with an Apache Web Server.

- **Checking Web Server Access**: Ensure the web server is reachable via its public IP.

- **Monitoring Instance Performance**: Track CPU usage with CloudWatch.

- **Resizing EC2 Resources**: Change the instance type and adjust the EBS volume size.

- **Testing and Terminating the Instance**: Test termination protection and then safely terminate the instance.

---  
⚠️ **Attention**: 
- All the tasks will be completed via the command line using AWS CLI. Ensure you have the necessary permissions. [Install AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
- Charges may apply for completing this lab. [AWS Pricing](https://aws.amazon.com/pricing/)

---

## Task 1 - Launch and Configure Your EC2 Instance

#### 1.1 Create the EC2 instance
Replace `<ami-0ebfd941bbafe70c6>` with the AMI of your choice and `t2.micro` with your preferred instance type
```bash
aws ec2 run-instances \
	--image-id ami-0ebfd941bbafe70c6 \
	--instance-type t2.micro \
	--associate-public-ip-address \
	--user-data file://user-data.sh \
	--instance-initiated-shutdown-behavior stop
```
*user-data.sh*
```bash
#!/bin/bash
# Installs the Apache web server            
yum -y install httpd
# Configures httpd to start on boot      
systemctl enable httpd
# Starts the httpd service now    
systemctl start httpd
# Creates an HTML homepage
echo '<html><h1>Hello From Your Web Server!</h1></html>' > /var/www/html/index.html 
```

<div align="center">
  <img src="screenshot/1.1.PNG"/>
</div>

---
⚠️ **Attention**:  
- Default VPC and Security Groups will be used if omitted.  
- Replace ami-0ebfd941bbafe70c6 if needed. [Find an AMI](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/finding-an-ami.html) 
- Adjust the user-data path for your OS:
   - Windows: --user-data file://C:/path/to/file.sh
   - Linux: --user-data file:///home/username/path/to/file.sh
- No key pair will be created as login is not required.
- Copy the instance ID for later use.

---

#### 1.2 Enable Termination Protection
Replace `<instance-id>` with the ID of your EC2 instance:
```bash
aws ec2 modify-instance-attribute --instance-ids <instance-id> --disable-api-termination
```

#### 1.3 Check Termination Protection Status
Replace `<instance-id>` with the ID of your EC2 instance:
```bash
aws ec2 describe-instance-attribute \
	--instance-ids <instance-id> \
	--attribute disableApiTermination
```
<div align="center">
  <img src="screenshot/1.2.PNG"/>
</div>

---

## Task 2 - Verify Web Server Accessibility

#### 2.1 Retrieve the security group ID:
Replace `<instance-id>` with the ID of your EC2 instance
```bash
aws ec2 describe-instances \
	--instance-ids <instance-id> \
	--query 'Reservations[*].Instances[*].SecurityGroups' \
	--output table
```

#### 2.2 Add inbound rules to allow HTTP traffic to the security group:
Replace `<sg-xxxxxxxx>` with your Security Group ID
```bash
aws ec2 authorize-security-group-ingress \
	--group-id sg-xxxxxxxx \
	--protocol tcp \
	--port 80 \
	--cidr 0.0.0.0/0
```
<div align="center">
  <img src="screenshot/2.0.PNG"/>
</div>

#### 2.3 Retrieve the public IPv4 address:
Replace `<instance-id>` with the ID of your EC2 instance
```bash
aws ec2 describe-instances \
	--instance-ids <instance-id> \
	--query 'Reservations[*].Instances[*].PublicIpAddress'
```
<div align="center">
  <img src="screenshot/2.1.PNG"/>
</div>

#### 2.4 Access the public IP in your browser to check if the page is working.

<div align="center">
  <img src="screenshot/2.2.PNG"/>
</div>

---

## Task 3 - Monitor EC2 Instance Performance

#### 3.1 Enable Basic Monitoring with CloudWatch
Replace `<instance-id>` with the ID of your EC2 instance
```bash
aws ec2 monitor-instances --instance-ids <instance-id>
```
<div align="center">
  <img src="screenshot/3.1.PNG"/>
</div>

#### 3.2 Check the EC2 Monitoring Data
Replace `<start-time>`, `<end-time>`, and `<instance-id>` with the appropriate values for your EC2 instance
```bash
aws cloudwatch get-metric-statistics \
--namespace AWS/EC2 \
--metric-name CPUUtilization \
--start-time <start-time> \
--end-time <end-time> \
--period 300 \
--statistics Average \
--dimensions Name=InstanceId,Value=<instance-id>
```
<div align="center">
  <img src="screenshot/3.2.PNG"/>
</div>

---

## Task 4 - Scale and Modify Your EC2 Resources

#### 4.1 Stop Instance
Replace `<instance-id>` with the ID of your EC2 instance
```bash
aws ec2 stop-instances --instance-ids <instance-id>
```

#### 4.2 Change the Instance Type 
Replace `<instance-id>` with the ID of your EC2 instance and `t3.nano` with your desired instance type
```bash
aws ec2 modify-instance-attribute --instance-ids <instance-id> --instance-type "t3.nano"
```

#### 4.3 Retrieve the EBS volume ID:
Replace `<instance-id>` with the ID of your EC2 instance
```bash
aws ec2 authorize-security-group-ingress \
	--instance-ids <instance-id> \
	--query 'Reservations[*].Instances[*].BlockDeviceMappings[*].[Ebs.VolumeId]' \
	--output table
```

#### 4.4 Modify the EBS volume
Replace `<volume-id>` with the ID of the EBS volume you want to modify
```bash
aws ec2 modify-volume --volume-id <volume-id> --size 10
```

### 4.5 Start Instance
Replace `<instance-id>` with the ID of your EC2 instance
```bash
aws ec2 start-instances --instance-ids <instance-id>
```

<div align="center">
  <img src="screenshot/4.1.PNG"/>
</div>

---

## Task 5 - Manage Termination Protection and Cleanup

#### 5.1 Test Termination Protection
Replace `<instance-id>` with the ID of your EC2 instance
```bash
aws ec2 terminate-instances --instance-ids <instance-id>
```

This will fail if termination protection is enabled.

<div align="center">
  <img src="screenshot/5.1.PNG"/>
</div>

#### 5.2 Disable Termination Protection
Replace `<instance-id>` with the ID of your EC2 instance
```bash
aws ec2 modify-instance-attribute --instance-ids <instance-id> --no-disable-api-termination
```

<div align="center">
  <img src="screenshot/5.2.PNG"/>
</div>

#### 5.3 Terminate the Instance
Replace `<instance-id>` with the ID of your EC2 instance
```bash
aws ec2 terminate-instances --instance-ids <instance-id>
```

#### 5.4 Verify the Instance Status
Replace `<instance-id>` with the ID of your EC2 instance
```bash
aws ec2 describe-instances \
	--instance-ids <instance-id> \
	--query 'Reservations[*].Instances[*].[InstanceId,State.Name]' \
	--output table
```

<div align="center">
  <img src="screenshot/5.3.PNG"/>
</div>

---

## Conclusion

Understanding AWS CLI is fundamental for creating Bash scripts that reduce boilerplate code and typos, accelerate architecture deployment, and provide code reuse. For more details, refer to the [AWS EC2 Documentation](https://docs.aws.amazon.com/ec2) and [AWS CLI Documentation](https://docs.aws.amazon.com/cli).
