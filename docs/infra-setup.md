# Infrastructure Setup : 

## Stage 0 : Setup Iam roles, Github Repo. Aws Billing alarms 

## Stage 1: setup infrastructure via terraform  

### Vpc.tf Setup : 
- 1 vpc
- 2 public subnets
- 2 private subnets
- IGW (internet gateway) 
- NAT gateway
- route tables
- confirm private subnets route outbound traffic via NAT gateway.
- Confirm public subnets route outbound traffic via Internet Gateway.
