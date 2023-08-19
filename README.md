# KCD Guatemala - Implementando Prometheus y Grafana en un cluster de Kubernetes en Amazon EKS

## Requirements
- AWS CLI
- EKSCTL
- kubectl
- HELM
- AWS Account

# Create EKS Cluster
```bash
# variable used in the lab
EKS_CLUSTER_NAME=kcdguatemala

# creating a basic cluster with 2 worker nodes
eksctl create cluster \
--name $EKS_CLUSTER_NAME \
--region=us-east-1 \
--nodegroup-name $EKS_CLUSTER_NAME-nodes \
--node-type t3.medium \
--nodes 2 \
--nodes-min 1 \
--nodes-max 4 \
--managed
```

### Deploy Nginx image
```bash
# Deploy
kubectl apply -f yml/nginx-deployment.yaml

# Check
kubectl get deployment -o wide
kubectl get pods

# Expose the pods to intenernet
kubectl apply -f yml/nginx-svc.yaml

# Check
kubectl get svc -o wide

```

### Installing Additionall Addons
#### EBS CSI controller
```bash
# Create IAM Open ID Connect provider for cluster
eksctl utils associate-iam-oidc-provider --cluster $EKS_CLUSTER_NAME --approve

# Check from IAM>Access Management>Identity Providers

# Create a role AmazonEKS_EBS_CSI_DriverRole and attached a managed IAM policy AmazonEBSCSIDriverPolicy
eksctl create iamserviceaccount \
  --name ebs-csi-controller-sa \
  --namespace kube-system \
  --cluster $EKS_CLUSTER_NAME \
  --attach-policy-arn arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy \
  --approve \
  --role-only \
  --role-name AmazonEKS_EBS_CSI_DriverRole

# Check the new resource from IAM and CloudFormation

# Validate
aws eks describe-cluster \
  --name $EKS_CLUSTER_NAME \
  --query "cluster.identity.oidc.issuer" \
  --output text

# Installing Amazon EBS CSI Driver
eksctl create addon --name aws-ebs-csi-driver --cluster $EKS_CLUSTER_NAME --service-account-role-arn "arn:aws:iam::$(aws sts get-caller-identity --query Account | jq -r):role/AmazonEKS_EBS_CSI_DriverRole" --force

# Check
# EKS > Clusters > Dev > Add-ons
kubectl get pods -n kube-system

```

## Install Prometheus
```bash
kubectl create ns prometheus
kubectl config set-context --current --namespace prometheus

helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm upgrade -i prometheus prometheus-community/prometheus \
  --namespace prometheus \
  --set alertmanager.persistentVolume.storageClass="gp2",server.persistentVolume.storageClass="gp2"

helm list

# Port forwards to the Prometheus server pod
kubectl port-forward -n prometheus deploy/prometheus-server 9090:9090
export POD_NAME=$(kubectl get pods --namespace prometheus -l "app.kubernetes.io/name=prometheus" -o jsonpath="{.items[0].metadata.name}")
kubectl --namespace prometheus port-forward $POD_NAME 9090
# Check prometheus dashboard http://127.0.0.1:9090

# Port forwards to the State metrics pod
kubectl port-forward -n prometheus deploy/prometheus-kube-state-metrics 8080:8080
# Check prometheus dashboard http://127.0.0.1:8080


# Port forwards to the Alertmanager pod
export POD_NAME=$(kubectl get pods --namespace prometheus -l "app.kubernetes.io/name=alertmanager" -o jsonpath="{.items[0].metadata.name}")
kubectl --namespace prometheus port-forward $POD_NAME 9093
# Check prometheus dashboard http://127.0.0.1:9093

# Port forwards to the PushGateway pod
kubectl port-forward -n prometheus deploy/prometheus-prometheus-pushgateway 9091:9091
export POD_NAME=$(kubectl get pods --namespace prometheus -l "app.kubernetes.io/name=prometheus-pushgateway" -o jsonpath="{.items[0].metadata.name}")
kubectl --namespace prometheus port-forward $POD_NAME 9091
# Check prometheus dashboard http://127.0.0.1:9091
```

### Install Grafana
Create the Grafana service with an external load balancer to get the public view.

```bash
kubectl create namespace grafana
kubectl config set-context --current --namespace grafana

helm install grafana grafana/grafana \
    --namespace grafana \
    --set persistence.storageClassName="gp2" \
    --set persistence.enabled=true \
    --set adminPassword='EKS!sAWSome' \
    --values yml/grafana.yaml \
    --set service.type=LoadBalancer

# Get your 'admin' user password by running
kubectl get secret --namespace grafana grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo

# check the LB
k get svc -n grafana

# get the URL for LB 
export ELB=$(kubectl get svc -n grafana grafana -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
echo "http://$ELB"
```
#### Import Dashboard to grafana
https://grafana.com/grafana/dashboards/3119-kubernetes-cluster-monitoring-via-prometheus/
https://grafana.com/grafana/dashboards/6149-system-metrics-single/


## Troubleshooting
How to Restart Kubernetes Pods With Kubectl
https://spacelift.io/blog/restart-kubernetes-pods-with-kubectl
```bash
kubectl rollout restart deployment prometheus-server

# Check you PVC state by running the command below.
kubectl describe pvc prometheus-alertmanager -n prometheus
```

Could not create volume in EC2: UnauthorizedOperatio
```bash

# status code: 403, request id: 1ea92baa-16ca-4129-8eeb-13041a944471
#  Warning  ProvisioningFailed  13m  ebs.csi.aws.com_ebs-csi-controller-7cd666c477-4vxf2_78bcbad7-ccce-44d5-9f69-86a030e065e1  failed to provision volume with StorageClass "gp2": rpc error: code = Internal desc = Could not create volume "pvc-e83bec60-f4b8-4b02-8ff5-c75c2ef4fcd6": could not create volume in EC2: UnauthorizedOperation: You are not authorized to perform this operation. Encoded authorization failure message: 6GgcQfsd6S2ixbqJmW0bog-uVj249GttDKOQ69ThBwob-mJXw4GJ7581dA_00XfElEf-WxG2YX11lcPSMwJWxMjLqeZ6viIflh02Q7aELRXOceVNmZQNzBQXNWzXjfBUtlPjM74DxwVMcEXV4CQGkK5Slm0KCN7XO2KCixslTgAyf7QYfheRa3_lAxdwNyQYUJyVkcI60uv0UKFb8uzFsXxM047sX28Lvo9tFQi8p4B_BA4Az2EKi9S4gnGrFok4Agvz32RqhSnGjkdzRkMIiHqv2bD5t0bTLBYwmYcC4S7We1svZWKbDZnjJ6xDbRW9uN8X8h4P6qjUHLUMACaog6luMVX_0-AxytM1_bnRakTpfGb0SU3-bVMReRXnQu0Ar0R9LZeWoEUVj2iVzeeQdabaT_BbQlubMdeoF7QyuFaqMrRox0W-42xDDhiMTb9T15qeYH9p5CA6FTW8jRW6uKv-q4tfDDEvMP-s9tCRkuDWeHew7cIbtuEmwi3lpY__5vpf1R7Hi4UvLmjsZE47Akx27Zzx8G7s3fOixVWmELuMZs5unLcgai-sSsay-PtmzGb0VVlPZ1_oGlk0DJuD1mYQSzCAtLYvFHjed6t_Tw9ZiskuKXCyCGzZ5vDnFr6rOZjezA_zJsvRNEhZ0QGLj-9V4npUAiVNWtSUR0Yg0i-mI4dpTRtxnEf4jiHY9CAw3WlfHxGrjq76-GAT3ioO4nsdogJLBnB5ubTqX9P3hoGr_g4liM8HduvLg2h6SIeMzVyC48AC892pK_WGoCmgqc-Bl_wLvJ3P8dkMxbWB-g

# solutions
helm uninstall prometheus
kubectl delete pvc storage-prometheus-alertmanager-0

aws sts decode-authorization-message --encoded-message MESSAGEHERE | jq -r .DecodedMessage | jq
"statementId": "DenyEbsVolumesHighIOPS",

k describe pvc storage-prometheus-alertmanager-0

# ACG restrictions
```

## Thanks
- https://awswithatiq.com/how-to-set-up-prometheus-and-grafana-in-eks/
- https://aws.plainenglish.io/monitor-eks-with-prometheus-grafana-4d3fc34d15f9