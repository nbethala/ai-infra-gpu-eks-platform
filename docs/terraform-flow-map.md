```
infra/terraform/
├── variables.tf          ◀──🔹 Declares root-level variables
│                         │    (e.g., region, project, account_id)
│                         │
├── terraform.tfvars      ◀──🔸 Optional: assigns values to root variables
│                         │    (e.g., region = "us-east-1")
│
├── main.tf               ◀──🔹 Passes root variables into modules
│                         │    (e.g., project = var.project)
│
├── modules/
│   ├── vpc/
│   │   ├── variables.tf  ◀──🔹 Declares what this module expects
│   │   └── main.tf       ◀──🔸 Uses those variables (e.g., var.project)
│
│   ├── iam/
│   │   ├── variables.tf  ◀──🔹 Declares expected inputs
│   │   └── main.tf       ◀──🔸 Uses them (e.g., var.account_id)
│
│   └── eks/
│       ├── variables.tf  ◀──🔹 Declares expected inputs
│       └── main.tf       ◀──🔸 Uses them (e.g., var.private_subnet_ids)
```

### Summary of Flow
 - Declare variables in infra/terraform/variables.tf
 - Assign values in terraform.tfvars or via CLI
 - Pass variables into modules via main.tf
 - Declare expected inputs in each module’s variables.tf
 - Use variables inside each module’s main.tf

 ### Variable declaratiom
- Root variables.tf: You’re saying “this is a variable I want to use in this project.”
-  Module variables.tf: You’re saying “this module needs this variable to work.”



Modular Terraform Lifecycle — Folder Structure
```
infra/terraform/
├── main.tf                  # Root orchestrator
├── terraform.tfvars         # Centralized variables
├── variables.tf             # Root-level variable declarations
├── Makefile                 # Command automation
├── modules/
│   ├── vpc/                 # VPC, subnets, NAT
│   ├── iam/                 # IAM roles for EKS + GPU nodes
│   ├── eks/                 # EKS control plane
│   ├── gpu_node_group/      # GPU Spot node group (modular, teardown-ready)
│   └── alb_irsa/            # IRSA role for ALB controller (optional)
```