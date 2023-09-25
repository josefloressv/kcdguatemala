# AWS CLI for EKS

Describe EKS cluster configuration
```bash
aws eks describe-cluster --name kcdguatemala
```

Retrieve your Amazon EKS cluster connection details, saving them into the ~/.kube/config file
```bash
aws eks update-kubeconfig --name kcdguatemala --region us-east-1
```
ws sts get-access-key-info --access-key-id AKIAZ5DU***Y2VNN
aws iam list-access-keys
aws iam list-access-keys --user-name cloud_user
aws iam get-access-key-info --access-key-id AKIAZ5DU***Y2VNN
aws eks get-token --cluster-name dev