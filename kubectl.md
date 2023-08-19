# kubectl

kubectl cluster-info

## Config
```bash
# contexts
kubectl config get-contexts
kubectl config current-context

kubectl config use-context contextname
kubectl config delete-context contextname

# clusters
kubectl config get-clusters
kubectl config delete-cluster clusterName

# users
kubectl config get-users
kubectl config delete-user userName
```

Retrieve your Amazon EKS cluster connection details, saving them into the ~/.kube/config file
```bash
aws eks update-kubeconfig --name clusterName --region us-east-1
aws eks get-token --cluster-name dev
```

## Namespaces
```bash
kubectl get ns
```
Configure a default namespace.
```bash
kubectl config set-context --current --namespace cloudacademy
```
## Nodes
```bash
kubectl get node -o wide
kubectl get node nodeName
kubectl describe nodes
```

## Services
```bash
kubectl get svc
kubectl get svc -o wide
kubectl apply -f ./nginx-svc.yaml
kubectl get pod
```

## ReplicaSet
```bash
kubectl get rs

# delete rs
kubectl delete replicaset ReplicaSetName -n NameSpaceName

```

## Deployments
```bash
kubectl get deployment
kubectl get deployment -o wide
kubectl apply -f ./nginx-deployment.yaml
```

## Pods
```bash
kubectl get pods
kubectl get pods -o wide
kubectl get pods --all-namespaces -o wide
kubectl get pods podName
kubectl get pods podName -o yaml
kubectl apply -f ./nginx-deployment.yaml

# Run a watch on the pods in the current namespace.
kubectl get pods --watch

# View the pods with the db label in the current namespace.
kubectl get pods -l role=db 

#Display  Pods, Persistent Volumes and Persistent Volume Claims in the same command
kubectl get pod,pv,pvc

# delete pods
kubectl delete pod PodName -n NameSpaceName

```

## EKS storage classes
```bash
kubectl get storageclass
```

# Logs
```bash
kubectl logs podName
```
