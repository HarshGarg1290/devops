output "cluster_id" {
  value = aws_eks_cluster.abrahimcse.id
}

output "node_group_id" {
  value = aws_eks_node_group.abrahimcse.id
}

output "vpc_id" {
  value = var.create_infra ? aws_vpc.abrahimcse_vpc[0].id : var.existing_vpc_id
}

output "subnet_ids" {
  value = var.create_infra ? aws_subnet.abrahimcse_subnet[*].id : var.existing_subnet_ids
}

# Useful connection outputs
output "cluster_endpoint" {
  description = "EKS cluster API server endpoint"
  value       = aws_eks_cluster.abrahimcse.endpoint
}

output "cluster_certificate_authority_data" {
  description = "Base64 encoded CA cert for kubeconfig"
  value       = aws_eks_cluster.abrahimcse.certificate_authority[0].data
}

output "kubeconfig_command_hint" {
  description = "Command hint to configure kubectl for this cluster (replace region if needed)"
  value       = "aws eks --region ap-southeast-1 update-kubeconfig --name ${aws_eks_cluster.abrahimcse.name}"
}
