# Hello world Python - CICD - with Github

### build an image
```
docker build -t hello-world-app1 .
docker build -t hello-world-app2 .
```

### tag with docker username/repo:tag (For Uploading)
```
docker tag hello-world-app1 gvr/hello-world-app1:1
docker tag hello-world-app2 gvr/hello-world-app2:1
```

### Run docker image (to test)
```
docker run -p 3000:3000 hello-world-app1
docker run -p 4000:4000 hello-world-app2
```

### Run docker image dettached mode
```
docker run -d -p 3000:3000 hello-world-app1
docker run -d -p 4000:4000 hello-world-app2
```

### Docker Content Trust (DCT)
```
docker trust key generate hwpython
docker trust key load key.pem --name hwpython
docker trust signer add --key cert.pem gvr1 example.com/hello-world-app1:1
docker trust sign example.com/hello-world-app1:1
docker trust inspect --pretty example.com/hello-world-app1
```

### Install kubernets using Minikube
 
```
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-darwin-amd64
sudo install minikube-darwin-amd64 /usr/local/bin/minikube

minikube start --memory=4098 --driver=hyperkit

minikube addons enable ingress

sudo minikube tunnel

echo "$(minikube ip) my-app.local" | sudo tee -a /etc/hosts

curl -H "Host: my-app.local" http://$(minikube ip)

```

### Install Agro CD Operator

# Operator Lifecycle Manager (OLM)
```
curl -sL https://github.com/operator-framework/operator-lifecycle-manager/releases/download/v0.30.0/install.sh | bash -s v0.30.0
```

Install the operator
```
kubectl create -f https://operatorhub.io/install/argocd-operator.yaml
```

Watch the operator come up 
```
kubectl get csv -n operators
```


### Kubernetes ingress controller Installation 
```
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
helm install nginx-ingress ingress-nginx/ingress-nginx
```
