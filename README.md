# DevSecOps CICD pipeline - Secure Cloud Deployment 

# About

This page is talks about securely deploy workloads in Kubernetes using CI & CD pipeline, including implementing code and container scanning, and managing vulnerabilities effectively.

# Objectives

- CI & CD pipeline
  - Code Quality Check
  - Credential scanning
  - static code analysis
  - dynamic code scanning
  - container image scanning
  - vulnerability management solution
  - Generate & Analyse SBOK
  - Build Docker image
  - Trivy image scan
  - Owasp dependency check
  - Integration test
  - Push Docker image
  - Publish artifacats:
  - Centralized GitOps AgroCD Server which deploys in Kubernetes clusters
- Kubernetes Security:
  - Role-Based Access Control
  - Network policies
  - Enforce Kubernetes security policies
  - Continuously scan & vulnerability management to running applications
  - Realtime monitoring and altering
  - Incident detection & automatic mitigation

# Pre Merge Workflow - CI Pipeline
![PreCI](/diagrams/images/Diagrams-PreCI.drawio.png)

## Commit Workflow

- Run linters to catch Python syntax or style errors (e.g., using flake8).
- Check for sensitive data using git-secrets.
- Format code using Black for Python.
- Run tests using a testing framework like pytest.

## Pre-commit hook setup prerequisites

- **flake8**: Install using pip install flake8.
  - **Coding style**: Flake8 **checks** against coding style guidelines, such as PEP 8
  - **Programming errors**: Flake8 detects and reports syntax errors, typos, and other potential bugs
  - **Complex constructs**: Flake8 checks for complex constructs in the code
- **git-secrets**: **Prevents** from committing passwords and other sensitive information
  - scans commits, commit messages, and --no-ff merges to prevent adding secret.
  - If a commit, commit message, or any commit in a --no-ff merge history matches one of your configured prohibited regular expression patterns, then the commit is rejected.
  - git secrets –scan
  - git secrets --scan-history
- **Black**: Install using pip install black.
  - PEP 8 compliant Python opinionated formatter
  - reformats entire files in place
- **pytest**: Install using pip install pytest.
  - Simplifies the process of writing and executing tests
  - Reduces boilerplate code, making tests more concise and expressive

Save the hello-world-py/git-hooks/pre-commit.sh script to.git/hooks/pre-commit in the repository chmod +x .git/hooks/pre-commit

## Pre-Push workflow

- - Run Python tests to ensure functionality and prevent breaking changes.
    - Enforce code coverage thresholds using coverage.py.
    - Verify commit messages follow the required pattern (SHK-12345).
    - Ensure compliance with Python code style rules using flake8.

### Pre-push hook setup prerequisites

- **flake8**: Install using pip install flake8.
  - **Coding style**: Flake8 checks against coding style guidelines, such as PEP 8
  - **Programming errors**: Flake8 detects and reports syntax errors, typos, and other potential bugs
  - **Complex constructs**: Flake8 checks for complex constructs in the code
- **pytest**: Install using pip install pytest.
  - Simplifies the process of writing and **executing tests**
  - Reduces boilerplate code, making tests more concise and expressive
- **coverage.py**: Install using pip install coverage.
  - **measuring code coverage** of Python programs
  - used to gauge the effectiveness of tests
- Save the hello-world-py/git-hooks/pre-push.sh script to.git/hooks/pre-push in the repository
- chmod +x .git/hooks/pre-commit  

### Jobs

1. **Trigger**:
    - The workflow triggers on every pull request targeting the main branch
2. **Platform Credentials/Secrets**:
    - Retrieve the platform specific Credentials/Secrets from Vault/secrets manager (encrypted with KMS key) dedicated IAM role
3. **SonarQube Scan**:
    - **Requires secrets**: SONAR_TOKEN and SONAR_HOST_URL.
    - **Purpose**: Perform static code analysis to detect code smells, bugs, and vulnerabilities.
    - **Security Benefits**:
        1. Integrates with SonarQube to analyze the codebase for quality and security issues.
        2. Requires SONAR_TOKEN for authentication with the SonarQube server.
        3. **Security Benefits**:
        4. Identifies potential vulnerabilities in the source code, such as SQL injection risks, cross-site scripting (XSS), and insecure configurations.
        5. Improves overall code quality, reducing the attack surface
4. **GitLeaks Secret Scan**:
    - **Purpose**: **Detect** for hardcoded secrets (e.g., API keys, tokens, credentials) in the codebase
    - Write regular expression rules
    - Outputs a report: gitleaks-report.json.
    - **Security Benefits:**
        1. Outputs results in JSON format for further analysis.
        2. **Security Benefits**:
            1. Detects and prevents accidental exposure of sensitive data in the codebase.
            2. Helps maintain compliance with security policies by avoiding secret leakage
    - **Command**: gitleaks detect/gitleaks git
5. **Snyk Security Scan (SCA)**:
    - **Purpose**: **Identify vulnerabilities** in dependencies and application code.
    - Requires SNYK_TOKEN for authentication.
    - Uses **Snyk CLI** to scan for known vulnerabilities and provides remediation advice.
    - **Security Benefits**:
        1. Detects vulnerabilities in third-party libraries, which are a common attack vector.
        2. Monitors for new vulnerabilities over time to maintain secure dependencies
        3. Remediation suggestions, SBOM tree, licence tree
6. **Python Auto Build**:
    - Checks if the Python code builds successfully.
    - Installs dependencies from requirements.txt.
    - Runs linting using flake8.
7. **Python Unit Tests**:
    - Executes unit tests using Python's built-in unittest framework.
    - Depends on the **Python Auto Build** job (needs: python-build).

# Release - Continuous Integration (CI) Pipeline
![CI](/diagrams/images/Diagrams-CI.drawio.png)

## Prerequisites:
- Add the following secrets in GitHub repository:
  - SONAR_TOKEN and SONAR_HOST_URL for SonarQube.
  - SNYK_TOKEN for Snyk.
  - DOCKERHUB_USERNAME and DOCKERHUB_PASSWORD for DockerHub.

## Jobs
1. **Trigger**:
    - Executes when a pull request is merged (on.pull_request with types: [closed]).
2. **Platform Credentials/Secrets**:
    - Retrieve the platform specific Credentials/Secrets from Vault/secrets manager (encrypted with KMS key) dedicated IAM role
3. **WorkItem/Story Link check:**
    - Verify commit has WorkItem/Story ticket link check
    - Verify the ticket status to assigned
    - **Security Benefits**:
        1. Ensures every commit has assigned ticket
4. **SonarQube (SAST)**:
    - **Requires secrets**: SONAR_TOKEN and SONAR_HOST_URL.
    - **Purpose**: Perform static code analysis to detect code smells, bugs, and vulnerabilities.
    - **Security Benefits**:
        1. Integrates with SonarQube to analyze the codebase for quality and security issues.
        2. Requires SONAR_TOKEN for authentication with the SonarQube server.
        3. Security Benefits:
        4. Identifies potential vulnerabilities in the source code, such as SQL injection risks, cross-site scripting (XSS), and insecure configurations.
        5. Improves overall code quality, reducing the attack surface
5. **Gitleaks**:
    - **Purpose**: Scan for hardcoded secrets (e.g., API keys, tokens, credentials) in the codebase
    - Write regular expression rules
    - Outputs a report: gitleaks-report.json.
    - **Security Benefits:**
        1. Outputs results in JSON format for further analysis.
        2. Security Benefits:
        3. Detects and prevents accidental exposure of sensitive data in the codebase.
        4. Helps maintain compliance with security policies by avoiding secret leakage
    - **Command**: gitleaks detect/gitleaks git
6. **Snyk Security Scan (SCA):**
    - **Purpose**: **Identify vulnerabilities** in dependencies and application code.
    - Requires SNYK_TOKEN for authentication.
    - Uses **Snyk CLI** to scan for known vulnerabilities and provides remediation advice.
    - **Security Benefits**:
        1. Detects vulnerabilities in third-party libraries, which are a common attack vector.
        2. Monitors for new vulnerabilities over time to maintain secure dependencies
        3. Remediation suggestions, SBOM tree, licence tree etc
7. **Syft**:
    - **Purpose**: Generate and analyze a software bill of materials (SBOM).
    - Uses the syft tool to create a **detailed inventory** of s/w components, dependencies and metadata of application.
    - The output (e.g., sbom.json) is used for further analysis.
    - **Security Benefits**:
        1. Provides **transparency** into the components and dependencies used.
        2. Helps with compliance (e.g., SBOM requirements under software supply chain standards).
8. **Grype**:
    - **Purpose**: Perform vulnerability analysis on the SBOM
    - Uses the grype tool to identify security risks based on the generated SBOM.
    - Outputs a report (grype-report.txt) for review.
    - **Security Benefits**:
    - Enhances supply chain security by ensuring all components are free of known vulnerabilities.
    - Pairs well with Syft to create a robust scanning pipeline
9. **Build Docker Image**:
    - **Purpose**: Builds a Docker image using App1-Dockerfile.
    - Uses the docker build command with the App1-Dockerfile.
    - **Security Benefits**:
    - Ensures reproducibility by building the image directly from the verified codebase.
    - Enables further security checks (e.g., Trivy scans) on the image
10. **Trivy**:
    - **Purpose**: Perform a comprehensive security scan of the built Docker image for vulnerabilities
    - Uses trivy to scan for vulnerabilities, misconfigurations, and secrets in the image.
    - Outputs results in JSON format.
    - **Security Benefits**:
        1. Ensures the container image is free from vulnerabilities before deployment.
        2. Scans for vulnerabilities at both the OS and application levels, reducing risks
11. **OWASP ZAP**:
    - **Purpose**: Perform dynamic application security testing (DAST) to identify runtime vulnerabilities
    - Uses the zaproxy/action-full-scan to run tests against a deployed instance of the app.
    - Requires configuration files (rules.yaml and context.yaml) for fine-tuned testing.
    - **Security Benefits**:
        1. Identifies vulnerabilities such as XSS, CSRF, and insecure cookies during runtime.
        2. Simulates real-world attacks to uncover vulnerabilities that static scans might miss
12. **Integration Tests**:
    - Verifies that the application functions correctly in an integrated environment.
    - **Security Benefits**:
    - Ensures that no security features or critical functionality are broken post-deployment.
    - Validates the end-to-end behavior of the application in a realistic environment
13. **Mutation Testing**: 
    - PITest introduces code mutations to assess test robustness

14. **Push to DockerHub**:
    - Pushes the verified Docker image to DockerHub.
    - Tags and pushes the image using credentials (DOCKER_USERNAME, DOCKER_PASSWORD).
    - **Security Benefits**:
    - Ensures images are stored in a secure and trusted registry.
    - Enables continuous monitoring for vulnerabilities in the published image
15. **Generate Artifact**:
    - Package and archive reports and outputs for auditing and sharing into a .tar.gz file.
    - Collects files (e.g., SBOM, vulnerability reports, logs) and packages them into a .tar.gz archive.
    - **Security Benefits**:
    - Provides an auditable trail of all security and quality checks performed.
    - Enables secure sharing of reports for further review or compliance purposes

# Continuous Deployment (CD) Pipeline
![CD](/diagrams/images/Diagrams-CD.drawio.png)

## Breakdown

1. **Checkout Artifacts**
    - Checkouts the artifacts published in the CI stage:
2. **Update Manifests**:
    - Typically it will be the shell script or Github Action to update the manifests
    - Performs YAML manifest file docker image update
3. **Agro CD Server**:
    - Centralized Agro CD server to deploy the workloads in Kubernetes clusters
4. **Kubernetes Clusters**
    - Highly available various Kubernetes Clusters

## Agro CD – configurations

Agro CD will be installed in the Centralized & Dedicated Kubernetes Cluster, which helps to deploy the workloads in multi cluster environment

- Helm based AgroCD installation in Dedicated Kubernetes Cluster
- Create dedicated Role for Administrator  

**Installation steps:** Refer ./k8s-setup/install_agrocd.sh

## Kubernetes Cluster – Configurations
![K8S](/diagrams/images/Diagrams-k8s.drawio.png)

### Resource Deployments

1. App1, App2 resources will be created with following:
    - **Namespaces**
        - There will be namespace called “dev” will be deployed
    - **Deployment**
        - app1, app2 kubernetes deployments
    - **Service**
        - app1-svc, app2-svc kubernetes service, type **CluserIP**
    - **HorizontalPodAutoScaler**
        - app1-hpa, app2-hpa will be deployed and mapped to deployment
        - minReplicas=1, maxReplicas=5
    - **ResourceQuota**
        - Set hard limits for dev namespace resource consumption
        - Min amount of 1 CPU requests allowed
        - Maximum amount of 2 CPU limit is allowed
        - Maximum amount of 1Gi memory is allowed
    - **Nginx Ingress Controller**
        - Deployed using helm, Refer - **./k8s-setup/install_ingress.sh**
        - ingress resource point to app1 will be deployed
        - canary ingress resource 80% canary weight to app2
        - annotation – to enable TLS encryption using valid certificate
        - annotation – to enforce secure communication
        - annotation – to enforce strong ciphers and protocols
        - annotation \- whitelist trusted IPs
        - annotation \- set request rate limits, protect against DDoS
        - annotation \- Enable logs for debugging
        - annotation – set custom and more headers
        - annotation – enable CORs
    - **Network Policies**
        - Default deny all ingress & egress traffic to namespace dev
        - Allow only traffic to app1 pod from ingress controller pods
        - Allow only traffic to app2 pod from ingress controller pods
        - Deny traffic incoming from app1 to app2
2. **Refer folder**: ./k8s-resources/\*.ya

## Kubernetes Cluster – Security Configurations

### RBAC 1 – Limit Kubernetes user to dev namespace

1. Create a User with access permissions to Namespace dev
2. Create a Kubernetes Role with actions such as get, list, watch, create, update and delete the resources such as pods, services and deployments
3. Create a Kubernetes User with Certificate-Based Authentication
    - Create a create a certificate-based user,
    - Certificate signing request (CSR)
    - Sign the CSR with the Kubernetes CA
4. Create Kubernetes RoleBinding which Bind the Role to User
5. Create a Kubernetes User Context limited to specific namespace dev

### RBAC 2 – limited cluster-wide permissions and access to uat namespace

1. Create a Kubernetes **Role** with actions such as get, list, watch, create, update and delete the resources such as pods, services and deployments
2. Create a Kubernetes **ClusterRole** with actions such as get, list on nodes
3. Create a Kubernetes User with Certificate-Based Authentication
    - Create a create a **certificate-based user**,
    - certificate signing request (CSR)
    - Sign the CSR with the Kubernetes CA
4. Create Kubernetes **RoleBinding** which Bind the Role to User
5. Create Kubernetes **ClusterRoleBinding** which Bind the **ClusterRole** to User

### Restrict Config maps to specific namespace

1. Create ServiceAccount called "svc_dev",
2. Create a role called "role1" and restrict to configmap only get/watch/list
3. Create RoleBinding called "rolebinding" with above "role1", "svc_dev"
4. Create test configmap "dev_cm" which has key value "Name": "GVR"
5. Create pod "dev_pod" with service account "svc_test", which should mount " dev_cm"

### Network Policies

1. Deny ingress and egress traffic by default
2. Allow communication from ingress pods to application pods
3. Deny intercommunication between pods

### Admission Controllers – PodSecurityAdmission

1. **Purpose**: Enforces namespace-level security policies for Pods based on Pod Security Standards (e.g., restricted, baseline, privileged).
2. **Security Benefit**:
    - Restrict running privileged containers.
    - Control capabilities like hostPID, hostNetwork, and hostIPC
    - Enforce the use of non-root users, specific AppArmor profiles, and Seccomp policies
        1. pod-security.kubernetes.io/enforce: baseline
        2. pod-security.kubernetes.io/enforce-version: v1.31
        3. pod-security.kubernetes.io/audit: restricted
        4. pod-security.kubernetes.io/audit-version: v1.31
        5. pod-security.kubernetes.io/warn: restricted
        6. pod-security.kubernetes.io/warn-version: v1.31

### Security policies – Enforce – Kyverno

- **Purpose**: A Kubernetes-native **policy engine** that enforces, validates, and mutates configurations **based on YAML-like policy definitions**.
- **Features**:
  - Automatically inject security configurations (e.g., readOnlyRootFilesystem: true).
  - Validate configurations (e.g., ensure only approved container images are used).
  - Generate default resources (e.g., network policies, resource quotas)
- **Example1**: Enforce readOnlyRootFilesystem for Containers
  - securityContext.readOnlyRootFilesystem = true
- **Example2**: Prevent Running Privileged Containers
  - securityContext. Privileged = false
- **Example3:** allow known Image Registries
  - containers.image = "trusted-registry.com/\*"
- **Example4**: Enforce Containers run as Non-Root User
  - securityContext.runAsNonRoot= false
- **Example5**: Enforce Resource requests and Limits
  - Containers.resources.requests.memory
  - Containers.resources.requests.cpu
  - Containers.resources.limit.memory
  - Containers.resources.limit.cpu
- **Example6**: Disallow use of latest image tag
  - containers image: "!\*:latest"
- **Example7**: Ensure Labels for Resource Identification
  - Pods must have 'app' and 'env' labels.
- **Example8**: Disallow the use of hostPath volumes
  - spec.volumes.hostpath: null
- **Example9**: Enforce a default deny all NetworkPolicy is applied to namespace
  - default-deny-all network policy
- **Example10: Audit Non-Compliant Resources**
  - Sdafsda
- **Example11**: Integrate Kyverno with image scanning tools (e.g., Trivy, Clair)
  - vulnerabilities.critical
- **Example12**: Disallow default service account
  - serviceAccountName == 'default'
- **Example13**: Set Image pull policy IfNotPresent
  - imagePullPolicy: "IfNotPresent"
- **Example14**: Generete default deny network policy
  - Deny Ingress and Egress traffic

### Security policies – Enforce – using Open Policy Agent (OPA) Gatekeeper

- **Purpose**: Enforces fine-grained, **custom policies using Rego**, a policy language. It works by validating and mutating resources based on defined constraints.
- **Features:**
  - Ensure all Pods use specific labels, annotations, or security contexts.
  - Restrict the use of certain container images.
  - Enforce naming conventions, RBAC rules, and more
- Set default **enforcementAction** to **deny**
- **Example1**: Namespace must have label env
- **Example2**: Restrict images from docker.io
- **Example3**: Resource names start with a specific prefix
- **Example3**: Ensures that all RBAC resources have a specific label

### Security & Benchmarking

- **Kubesec:**
  - Security risk analysis for Kubernetes resources
  - Can Deploy as Admission controller to evaluate the score of resources
- **Kube-bench:**
  - Tool to check Kubernetes cluster CIS Kubernetes Benchmarks
  - Can Deploy as a POD in a Kubernetes cluster

### Runtime Security & Continuous Vulnerability Monitoring

- **Prerequisites**
  - Access to Aqua Console:
    - Ensure Aqua Security Platform is installed and configured.
  - Cloud Permissions:
    - Appropriate access rights for cloud infrastructure scanning.
  - Access to Applications:
    - Permission to monitor your workloads and applications.
- **Install Aqua Platform**
  - kube-bench
    - Threat assessment tool
  - kube-enforecer
    - alerts to multiple destinations
- **Enable Runtime Protection**
  - **Aqua Enforcers**:
    - Install **Aqua Enforcers** on your nodes. Enforcers monitor container and application activity and report back to the Aqua Console.

### GKE 
- Google Cloud Security Command Center (SCC): Performs real-time security monitoring at runtime
- Kubernetes Threat Detection (KTD): Monitors GKE for malicious or suspicious activity

### Runtime syscall monitoring using Falco Rules

- Create falco rules to detect and alerts on any behavior that involves making Linux system calls

#### Admission Controllers

- **Security policies – AlwaysPullImages**
  - **Purpose**: Forces every Pod to pull container images before starting, even if the image is already cached on the node.
  - **Security Benefit**: Prevents Pods from using potentially stale or tampered images from the local node cache.
- **Security policies – LimitRanger**
  - **Purpose**: Ensures Pods and containers have appropriate CPU/memory requests and limits defined.
  - **Security Benefit**: Prevents resource exhaustion in the cluster.
- **Security policies – ResourceQuota**
  - **Purpose**: Enforces resource quotas at the namespace level.
  - **Security Benefit**: Prevents denial-of-service (DoS) attacks by limiting resource consumption.
- **Security policies – DenyEscalatingExec**
  - **Purpose**: Blocks exec and attach commands to privileged containers.
  - **Security Benefit**: Prevents privilege escalation through interactive access to sensitive containers.

### Enable the AuditLogs for Control plane components

- The cluster audits the activities
- generated by users, by applications that use the Kubernetes API
- and control plane as well
- **Example**: When someone delete the pod/deployment/service in PROD namespace; log it  

### Don't run containers in privileged mode (privileged = false)

- The cluster audits the activities

### Use kernel hardening tools such as AppArmor, seccomp

- restricting the system calls & Kernel Security Module to granular access control for programs

### Adopt Service Mesh for pod to pod encryption using mTLS

- mTLS: Is secure communication between pods
- With service mesh Istio & Linkerd mTLS is easier, managable
- mTLS can be Enforced or Strict

### Use Distroless/Slim/Minimal Images

- Distroless Images will have only your app & runtime dependencies
- No package managers, shell, n/w tools, text editors etc
- Distroless images are very small

### Encrypt Kubernetes secrets

- For EKS, GKE or AKS clusters, encrypt the secrets with its dedicated CMK keys

### Leverage botkube live monitoring for all namespaces and all activities

- Leverage opensource troubleshooting and monitoring tool “botkube” which helps to provide live event alerts namespaces and events.

### Monitoring and Runtime Security
- Coralogix monitors the web application’s UI for errors, performance, and logs

### Setup Prometheus Server & Grafana Operator to monitor Kubernetes workloads

- Setup Prometheus & Grafana Operator framework in dedicated monitoring server/cluster
- Monitor metrics, time series data
- Configure scrape targets and service discovery for audit, history and monitoring purpose

### SSL Certification and Application Access
- SSL certificates are installed to secure web application access.

### Application Penetration Testing
- A manual penetration test using Burp Suite Professional is performed to identify any vulnerabilities that automated tests may have missed

# Technical Details of the Project

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
