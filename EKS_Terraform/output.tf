output "cluster_id" {
  value = aws_eks_cluster.abrahimcse.id
}

output "node_group_id" {
  value = aws_eks_node_group.abrahimcse.id
}

output "vpc_id" {
  value = aws_vpc.abrahimcse_vpc.id
}

output "subnet_ids" {
  value = aws_subnet.abrahimcse_subnet[*].id
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
  description = "Command hint to configure kubectl for this cluster"
  value       = "aws eks --region ${aws_eks_cluster.abrahimcse.region} update-kubeconfig --name ${aws_eks_cluster.abrahimcse.name}"
}
