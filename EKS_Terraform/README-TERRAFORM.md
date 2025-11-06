EKS Terraform — how to provision and deploy the app

This folder contains Terraform configuration to create an AWS EKS cluster and related VPC resources.

Important: running Terraform requires valid AWS credentials (AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, and optionally AWS_SESSION_TOKEN) with sufficient permissions.

Recommended workflow (local machine or CI runner):

1) Pre-requirements
   - Install Terraform >= 1.3
   - Install AWS CLI v2 and configure with `aws configure` or environment variables
   - Install kubectl
   - Install Helm (for chart deployment)

2) (Optional) Configure a remote state backend
   - For team use, enable an S3 backend and a DynamoDB table for state locking. You can uncomment and change the backend block in `main.tf`.

3) Initialize Terraform

   cd EKS_Terraform
   terraform init

4) Validate and plan

   terraform validate
   terraform plan -out eks.plan

   Inspect the plan carefully before applying.

5) Apply (creates VPC, subnets, IAM roles, EKS cluster and node group)

   terraform apply "eks.plan"

6) Configure kubectl

   After apply finishes, run:

   aws eks --region <region> update-kubeconfig --name <cluster-name>

   (You can get the exact command from the Terraform output `kubeconfig_command_hint`.)

7) Deploy the application Helm chart

   From the repository root (FullStack-Blogging-App):

   # ensure your image is built and pushed to a registry reachable by the cluster
   # Jenkinsfile builds and pushes image to abrahimcse/bloggingapp:latest by default

   helm upgrade --install bloggingapp ./k8s/helm/FullStack-Blogging-App -n webapps --create-namespace \
     --set image.repository=abrahimcse/bloggingapp --set image.tag=latest

8) Verify

   kubectl get pods -n webapps
   kubectl get svc -n webapps

Notes and recommendations
- Review and harden security group rules before running in production.
- Consider using the official Terraform EKS module (terraform-aws-modules/eks/aws) for production readiness.
- Add provider version pins and a remote backend for collaborative workflows (we added provider pinning; customize backend). 
- If you want Terraform to also install the Helm chart, we can add a `helm_release` resource — tell me if you want that and I'll add it (it requires the Helm provider and proper kubeconfig wiring in Terraform).
 
## Important: do NOT commit `.terraform` or provider binaries

Do not commit the `.terraform` directory, provider binaries, or any `*.tfstate` files to git. These are local artifacts (provider plugins, caches, and state) and can be very large; committing them will exceed GitHub's file size limits and pollute repository history.

To set up your local working directory (or CI), run:

```bash
cd EKS_Terraform
terraform init
```

This downloads provider plugins into the local `.terraform` directory. If you accidentally commit a provider binary or state file to the repo, contact the repository owner — removing it from remote history may require a history rewrite (force-push) or migration to Git LFS.

If you must keep large binaries, use Git LFS and migrate existing large objects to LFS before pushing. Prefer not to store provider binaries in source control.
 