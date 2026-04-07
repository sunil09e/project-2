# 🚀 Application Deployment using CI/CD (Jenkins + Docker + EKS + Terraform)

# 📌 Project Overview

This project demonstrates an end-to-end DevOps pipeline to deploy a React application into a production-ready Kubernetes environment (AWS EKS) using:

- Jenkins (CI/CD)

- Docker (Containerization)

- Terraform (Infrastructure as Code)

- Kubernetes (EKS)

- Prometheus & Grafana (Monitoring)


# 🏗️ Architecture

GitHub → Jenkins → Docker → DockerHub → EKS (Kubernetes) → Monitoring

# ⚙️ Prerequisites

Make sure you have:

- AWS Account

- IAM User with permissions

- Terraform installed

- AWS CLI configured

- Docker installed

- kubectl installed

- eksctl installed

- Jenkins server

# ⚙️ Setup Instructions

**Clone repository**

git clone https://github.com/Vennilavanguvi/Trend.git

cd Trend

# 🐳 Docker Commands

Create a Dockerfile in the project directory  

**Build Docker image**

docker build -t trend-app:v1 .

**Run container**

docker run -d -p 3000:80 trend-app:v1

👉 Open: http://localhost:3000

**Tag image**

docker tag trend-app:v1 crazy1/trend-app:v1

**Login DockerHub**

docker login

**Push image**

docker push crazy1/trend-app:v1

# ☁️ Terraform

**📌 Description**

- Define infrastructure in `main.tf` to create VPC, IAM, EC2 (Jenkins), and other required resources.

- Jenkins is installed automatically on EC2 using **user data script** defined inside Terraform (`main.tf`).  

- When the EC2 instance launches, the script runs and installs Jenkins.

🚀 Terraform commands 

**Initialize Terraform**

terraform init

**Validate configuration**

terraform validate

**Preview infrastructure changes**

terraform plan

**Create infrastructure**

terraform apply

- Ensure AWS CLI is configured before running Terraform

- Provide correct region (e.g., ap-south-1)  

- EC2 instance will be used to host Jenkins


# 🌐 Access Jenkins

 Get EC2 public IP (from AWS console)

**Open in browser**

http://EC2-PUBLIC-IP:8080

**🔑 Get Initial Admin Password**

sudo cat /var/lib/jenkins/secrets/initialAdminPassword

**Installed Required Plugins**

We added plugins needed for DevOps pipeline:

- Git plugin → to connect GitHub

- Docker plugin → to build images

- Pipeline plugin → to create CI/CD

- Kubernetes plugin (optional)

**Configured Credentials**

Added credentials in Jenkins:

GitHub credentials

DockerHub username & password

Used in pipeline securely

**Connected GitHub (Webhook)**

Configured webhook in GitHub repo

URL:
http://JENKINS-IP:8080/github-webhook/

So whenever code is pushed → Jenkins triggers automatically

**Create a Pipeline Job**

Create New Item → Pipeline

**🔧 General Configuration**

Enable GitHub Project

Add repository URL:

https://github.com/suni109e/project-2

**🔔 Build Triggers**

Enable: ✅ GitHub hook trigger for GITScm polling

👉 This allows Jenkins to automatically trigger the pipeline whenever code is pushed to GitHub.

**📂 Pipeline Configuration**

**🔹 Definition**

Select: Pipeline script from SCM

This means:

Jenkins will look for a file named Jenkinsfile in your repo

If not present → pipeline will fail ❌

**🔹 SCM Configuration**

SCM: Git

Repository URL:

https://github.com/suni109e/project-2.git

Credentials: Configured (GitHub access)

**🔹 Branch Configuration**

Branch Specifier:

*/main

👉 This ensures pipeline runs for the main branch

# Pipeline Stages (What Jenkins does)

🔹 Stage 1: git clone <repo>

🔹 Stage 2: Build Docker Image

🔹 Stage 3: Push to DockerHub

🔹 Stage 4: Deploy to Kubernetes

 **📂 Notes**

- Jenkins runs on port 8080  

- Ensure security group allows port 8080  

- User data runs only during instance launch  

- If it fails, check logs:

     Check user data logs

     sudo cat /var/log/cloud-init-output.log






# 🐙 Kubernetes 

**Create cluster**

eksctl create cluster --name trend-cluster --region ap-south-1

**Update kubeconfig**

aws eks --region ap-south-1 update-kubeconfig --name trend-cluster

**Check nodes**

kubectl get nodes

**Deploy application**

kubectl apply -f kubernetes/deployment.yaml

kubectl apply -f kubernetes/service.yaml

**Check pods**

kubectl get pods


**Check services**

kubectl get svc

**🔐 IAM Role Mapping in Kubernetes**

- Added AWS IAM Role ARN to the aws-auth ConfigMap in the kube-system namespace

- This mapping allows external entities (like Jenkins/EC2) to access the EKS cluster using kubectl

- Assigned the role to system:masters group to provide admin-level access

- Ensures secure authentication between AWS IAM and Kubernetes RBAC

# 📊 Monitoring Commands (Prometheus + Grafana)

**📌 Description**
 
Helm is a package manager for Kubernetes that helps to install, manage, and upgrade applications using Helm charts.

It creates pods for:

**📦 Components**

- Prometheus → collects metrics

- Grafana → dashboard UI

- Alertmanager → alerts

- Node Exporter → node-level metrics

- Kube-state-metrics → Kubernetes metrics

**Insatll Helm**

curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-4 | bash

**Add Helm repo**

helm repo add prometheus-community https://prometheus-community.github.io/helm-charts

helm repo update

**Install monitoring stack**

helm install monitoring prometheus-community/kube-prometheus-stack

**Access Grafana**

kubectl port-forward svc/monitoring-grafana 3000:80

username: admin

get password: kubectl get secret monitoring-grafana -o jsonpath="{.data.admin-password}" | base64 --decode

**Access Prometheus**

kubectl port-forward svc/monitoring-kube-prometheus-prometheus 9090:9090




# 🌐 Access Application

kubectl get svc

Copy LoadBalancer EXTERNAL-IP and open in browser

LoadBalancer URL: http://a42630106c0834fce891665f01cb6b11-1496532061.ap-south-1.elb.amazonaws.com

# ⭐ Conclusion

This project demonstrates a complete DevOps CI/CD pipeline by automating application deployment on AWS EKS using Terraform, Docker, Jenkins, and Kubernetes with monitoring using Prometheus and Grafana.



















