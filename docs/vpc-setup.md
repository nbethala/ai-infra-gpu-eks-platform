# Stage 1.1: VPC Setup

## 🌐 Why
A Virtual Private Cloud (VPC) provides the foundation for secure networking.  
- **Public subnets** host ingress resources (e.g., Application Load Balancer).  
- **Private subnets** host EKS worker nodes and GPU workloads, shielded from direct internet exposure.  
- **NAT gateway** allows private nodes to pull images and updates without being directly exposed.  

This design demonstrates network segmentation, secure egress, and cost discipline — key skills for cloud architects.

## ⚙️ How
- Provisioned a VPC (`10.0.0.0/16`) with DNS support enabled.  
- Created two public subnets (`10.0.1.0/24`, `10.0.2.0/24`) across availability zones.  
- Created two private subnets (`10.0.3.0/24`, `10.0.4.0/24`) across availability zones.  
- Attached an Internet Gateway for public subnets.  
- Provisioned a single NAT Gateway in a public subnet for outbound traffic from private subnets.  
- Configured route tables:  
  - Public → Internet Gateway  
  - Private → NAT Gateway  
- Applied tags to all resources:  
  - `project=gpu-e2e`  
  - `owner=Nancy`

## ✅ Validation
- Confirmed public subnets route outbound traffic via Internet Gateway.  
- Confirmed private subnets route outbound traffic via NAT Gateway.  
- Verified tags applied consistently across all resources.  

I provisioned a VPC with segmented public/private subnets and a NAT gateway. Public subnets host ingress (ALB), while private subnets host GPU workloads shielded from direct internet exposure. Outbound traffic flows securely via NAT. All resources are tag‑gated (`project=gpu-e2e`, `owner=Nancy`) to enforce cost tracking and teardown hygiene.

                   +-------------------+
                   |   VPC: gpu-e2e    |
                   |   CIDR: 10.0.0.0/16|
                   +-------------------+
                            |
        -------------------------------------------------
        |                                               |
+-------------------+                         +-------------------+
| Public Subnet A   |                         | Public Subnet B   |
| CIDR: 10.0.1.0/24 |                         | CIDR: 10.0.2.0/24 |
| AZ: region-a      |                         | AZ: region-b      |
| IGW route → 0.0.0.0/0                       | IGW route → 0.0.0.0/0
+-------------------+                         +-------------------+
        |                                               |
        |                                               |
        |                                               |
+-------------------+                         +-------------------+
| Private Subnet A  |                         | Private Subnet B  |
| CIDR: 10.0.3.0/24 |                         | CIDR: 10.0.4.0/24 |
| AZ: region-a      |                         | AZ: region-b      |
| NAT route → 0.0.0.0/0                       | NAT route → 0.0.0.0/0
+-------------------+                         +-------------------+

                 +-------------------+
                 | Internet Gateway  |
                 | gpu-e2e-igw       |
                 +-------------------+

                 +-------------------+
                 | NAT Gateway       |
                 | gpu-e2e-nat       |
                 | EIP attached      |
                 +-------------------+

