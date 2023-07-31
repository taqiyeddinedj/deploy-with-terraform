# Deployment with Terraform
![aws_terraform drawio](https://github.com/taqiyeddinedj/deploy-with-terraform/assets/112349513/2ea11de9-a23c-462f-bf2f-e09b856a892a)

Two-Tier Web App Deployment with Terraform
This repository contains the code to deploy a two-tier web application on AWS using Terraform. The infrastructure consists of a load balancer, two web server instances, and associated networking resources, all provisioned as code.
# NOTE 
I installed apache instead of nginx, i am lazy to cange it lol
# Features
Creates a Virtual Private Cloud (VPC) with public subnets spread across different availability zones.
Sets up an Internet Gateway for public internet access.
Creates security groups to control access to the instances and load balancer.
Spins up two EC2 instances with Nginx web server installed, serving as the web tier.
Deploys an Elastic Load Balancer (ELB) to distribute traffic across the web server instances.
The instances and ELB are secured with appropriate security groups.
User data scripts are used to install and configure apache on the instances.
# Prerequisites
An AWS account with appropriate IAM permissions to create resources.
Terraform installed on your local machine.
How to Use
Clone this repository to your local machine.
Make sure you have your AWS credentials configured for Terraform.
Customize the variables in terraform.tfvars if needed (e.g., key_name, network_address_space, etc.).
Execute terraform init to initialize the Terraform configuration.
Run terraform apply to create the infrastructure on AWS.
Access the web application using the public DNS name of the ELB provided in the output.
# File Structure
main.tf: Contains the Terraform configuration for creating the infrastructure.

terraform.tfvars: Sets the values for the input variables.

nginx-install.sh: User data script to install and configure Nginx on EC2 instances.

README.md: Provides an overview and instructions for using the repository.
# Outputs
The public DNS name of the Elastic Load Balancer (ELB) is provided as an output to access the web application.
Notes
This deployment is suitable for testing and educational purposes; it may require further configuration for production use.
Remember to destroy the resources after use to avoid unnecessary AWS charges: terraform destroy.
Happy Deploying!

Feel free to customize the description further based on your specific use case or add any additional information you think is relevant.
