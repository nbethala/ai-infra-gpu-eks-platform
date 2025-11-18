# IAM Setup (Operator, CI, ALB Controller) - design secure access patterns

## Create AWS IAM role/user with least privilege (EKS, EC2, IAM, ECR, ALB, S3)

### Operator Role (NancyOperatorRole): human access
- Create IAM role NancyOperatorRole.
- Trust policy requires MFA (aws:MultiFactorAuthPresent = true).
- Attach operator.json policy (EKS, EC2 describe, ECR, S3, ALB, CloudFormation).
- Add permission boundary to deny untagged resources.
- Assume role with MFA when running Terraform manually.
- WHY : set permission boundaries. don't overly rely on admin accounts.   

### CI Role (CICD_EKS_GPU_Role): secure automation 
- GitHub OIDC provider (https://token.actions.githubusercontent.com).
- Create IAM role CICD_EKS_GPU_Role with trust policy restricted to your branch
- Attach ci.json policy (cluster/nodegroup lifecycle, ECR push, S3 artifacts, ALB creation)
- GitHub Actions - configure aws-actions/configure-aws-credentials to assume this role.
- WHY : GitHub Actions assumes a role via OIDC federation, no static keys.

### AWS Load Balancer Controller Role (ALBControllerIRSA) : 
- Create IAM policy alb.json (ALB, EC2 describe, WAF, Shield).
- Create IAM role ALBControllerIRSA with trust to EKS OIDC provider.
- Condition: only system:serviceaccount:kube-system:aws-load-balancer-controller
- Annotate the controller’s service account with the role ARN.
- Controller pods now create/manage ALBs securely, without static credentials.
- WHY : Kubernetes‑AWS integration - pods assume IAM roles via service accounts (no keys).





                +-------------------+
                |   AWS Account     |
                |  (IAM Policies)   |
                +-------------------+
                         ^
                         |
   -----------------------+-----------------------
   |                      |                      |
   |                      |                      |
+--------+          +----------------+     +---------------------+
| Nancy  |          | GitHub Actions |     | Kubernetes Service  |
| Human  |          |   Workflow     |     | Account (ALB Ctrl)  |
+--------+          +----------------+     +---------------------+
     |                      |                      |
     | AssumeRole (MFA)     | OIDC Federation      | OIDC Federation
     v                      v                      v
+----------------+    +----------------+     +---------------------+
| Operator Role  |    | CI Role        |     | ALB Controller Role |
| NancyOperator  |    | CICD_EKS_GPU   |     | ALBControllerIRSA   |
+----------------+    +----------------+     +---------------------+
     |                      |                      |
     | Permissions:         | Permissions:         | Permissions:
     | - EKS, EC2           | - EKS lifecycle      | - ALB mgmt
     | - ECR, S3            | - ECR push/pull      | - EC2 describe
     | - ALB, CFN           | - S3 artifacts       | - WAF, Shield
     v                      v                      v
+---------------------------------------------------------------+
|                     AWS Services                              |
|   EKS | EC2 | ECR | S3 | ALB | CloudFormation | Logs | Route53 |
+---------------------------------------------------------------+
