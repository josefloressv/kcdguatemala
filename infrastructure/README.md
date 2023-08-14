# Learn Terraform - Provision an EKS Cluster

This repo is a companion repo to the [Provision an EKS Cluster tutorial](https://developer.hashicorp.com/terraform/tutorials/kubernetes/eks), containing
Terraform configuration files to provision an EKS cluster on AWS.

## Interact eksctl and kubectl
```bash
# Retrieve your Amazon EKS cluster connection details, saving them into the ~/.kube/config file
aws eks update-kubeconfig --name clusterName --region us-east-1
```