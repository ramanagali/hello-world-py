# Hello world Python - GitOps CICD with AgroCD

## Overview
This project has simple python based apps, its docker files, kubernetes deployment manifests and GitOps, k8s secure configuration setup etc


## Project tree

```bash
.
├── App1-Dockerfile
├── App2-Dockerfile
├── README.md
├── diagrams
│   └── Diagrams.drawio
├── git-hooks
│   ├── pre-commit.sh
│   └── pre-push.sh
├── k8s-manifests
│   ├── app1.yaml
│   ├── app2.yaml
│   ├── ingress.yaml
│   ├── ingress2.yaml
│   └── netpol.yaml
├── k8s-setup
│   ├── agrocd
│   │   ├── link-github.yaml
│   │   └── values.yaml
│   ├── gatekeeper
│   │   ├── adminlabel.yaml
│   │   ├── disallow_dockerhub.yaml
│   │   ├── k8srequirednameprefix.yaml
│   │   └── ns_labels.yaml
│   ├── install_agrocd.sh
│   ├── install_ingress.sh
│   ├── kyverno
│   │   ├── audit-non-compliant-res.yaml
│   │   ├── disallow-default.sa.yaml
│   │   ├── disallow-hostpath-volumes.yaml
│   │   ├── disallow-latest-tag.yaml
│   │   ├── disallow-privileged.yaml
│   │   ├── enforce-default-netpol.yaml
│   │   ├── enforce-labels.yaml
│   │   ├── enforce-nonroot-user.yaml
│   │   ├── enforce-resource-limit.yaml
│   │   ├── enfore-read-root-filesys.yaml
│   │   ├── generete-default-np.yaml
│   │   ├── restrict-registry.yaml
│   │   ├── set-image-pull-policy.yaml
│   │   └── validate-image-scan.yaml
│   ├── kyverno_install.sh
│   ├── opa_gatekeeper.sh
│   ├── rbac1
│   │   ├── dev-role.yaml
│   │   └── dev-rolebinding.yaml
│   ├── rbac1.sh
│   ├── rbac2
│   │   ├── uat-role.yaml
│   │   └── uat-rolebinding.yaml
│   └── rbac2.sh
├── src
│   ├── app1
│   │   ├── app.py
│   │   └── requirements.txt
│   └── app2
│       ├── app.py
│       └── requirements.tx
```

### build an image
```
docker build -t hello-world-app1 -f App1-Dockerfile .
docker build -t hello-world-app1 -f App1-Dockerfile .
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

# docker must be installed inorder to use hyperkit
minikube start --memory=4098 --driver=hyperkit

minikube addons enable ingress

sudo minikube tunnel

echo "$(minikube ip) my-app.local" | sudo tee -a /etc/hosts

curl -H "Host: my-app.local" http://$(minikube ip)

```
