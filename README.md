1. Create VPC(aws_vpc) and Subnet(aws_subnet)
To begin with, you need to create a subnet in AWS using Terraform, you can use the [aws_subnet][14] resource.

Refer to the following terraform code -

2. Create Security Group(aws_security_group)
After creating the VPC, Subnet you need to create Security Group. In the security group you can specify the Ingress as well Egress rules based on the ports which you need to open.

For this example, I am allowing SSH and enabling PORT 22`.
The above terraform configuration will create a security group that allows inbound SSH traffic from any IP address and allows all outbound traffic.
The security group is placed in the specified VPC using the aws_vpc resource.

You can customize the security group by specifying different options for the aws_security_group resource. For example,
you can add additional ingress or egress rules to allow or block specific traffic, or
specify different IP ranges or protocols. You can also add tags to the security group to organize and identify it.

3. Create Application Load Balancer (aws_lb) and Load Balancer Listener (aws_lb_listener)
The third step would be to create an ALB with a listener that listens for HTTP traffic on port 80.
 The ALB is placed in the specified security group and subnets and
 is configured to forward traffic to a target group using the aws_lb_target_group resource.
