## 🌐 Networking Architecture

This platform is deployed on **AWS EKS** using a **VPC with private subnets** to ensure GPU inference nodes remain isolated from the public internet.

### Key Points
- **Private Subnets** → EKS worker nodes and Triton pods run here, with no public IPs.
- **Public Subnets** → Host NAT Gateway and Load Balancers for controlled ingress/egress.
- **NAT Gateway** → Allows private nodes to pull Docker images and send outbound traffic securely.
- **Internet Gateway** → Connects the VPC to the internet, but only via NAT or Load Balancer.
- **Route Tables** → 
  - Public subnet routes `0.0.0.0/0` → Internet Gateway.
  - Private subnet routes `0.0.0.0/0` → NAT Gateway.

### ✅ Outcome
- Secure isolation of GPU workloads.
- Controlled outbound access for updates and image pulls.
- Best‑practice architecture for production EKS clusters.


## 🌐 Networking Flow: Private Subnet + NAT Gateway - Private VPC 

                ┌───────────────────────────┐
                │        Internet           │
                └─────────────▲─────────────┘
                              │
                              │
                ┌─────────────┴─────────────┐
                │   Internet Gateway (IGW)  │
                └─────────────▲─────────────┘
                              │
                              │
                ┌─────────────┴─────────────┐
                │   Public Subnet           │
                │   - NAT Gateway           │
                │   - Load Balancer (ALB)   │
                └─────────────▲─────────────┘
                              │
                              │
                ┌─────────────┴─────────────┐
                │   Private Subnet          │
                │   - EKS Worker Nodes      │
                │   - GPU Pods (Triton)     │
                └─────────────┬─────────────┘
                              │
                              ▼
                ┌───────────────────────────┐
                │   Internal VPC Traffic    │
                │   (Pods, Services, DBs)   │
                └───────────────────────────┘

---

### 🔎 Flow Explanation
- **Private Subnet**: EKS nodes and GPU workloads live here, no public IPs.
- **NAT Gateway**: In the public subnet, forwards outbound traffic from private nodes to the internet.
- **Internet Gateway (IGW)**: Connects the VPC to the internet.
- **Inbound Traffic**: Comes through a Load Balancer in the public subnet, then routed to private pods.
- **Outbound Traffic**: Private nodes → NAT Gateway → IGW → Internet (e.g., pulling Docker images).
