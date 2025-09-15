# PetClinic DevOps CI/CD Pipeline on Azure

This project extends the **Spring PetClinic** application with full **DevOps and Cloud Infrastructure** automation.  
It demonstrates how to build, containerize, provision infrastructure, and deploy PetClinic using modern CI/CD practices.

---

## 🚀 Project Overview

- **Application**: Spring Boot PetClinic (Java)
- **Infrastructure**: Terraform on Azure (Resource Group, AKS, Networking, etc.)
- **Containerization**: Docker & Docker Compose (for local DBs and app)
- **Orchestration**: Kubernetes manifests (`k8s/` for database + app)
- **CI/CD**: Jenkins pipeline (`Jenkinsfile`)
- **Developer Environment**: VS Code DevContainer (`.devcontainer/`)

---

## 📂 Repository Structure

```
.
├── infra/              # Terraform IaC for Azure
├── k8s/                # Kubernetes manifests for DB + PetClinic
├── .devcontainer/      # VS Code dev environment
├── docker-compose.yml  # Local dev database setup
├── Jenkinsfile         # CI/CD pipeline definition
├── src/                # PetClinic Spring Boot source
└── README.md
```

---

## ⚡ Quick Start (Local Development)

### Run Databases with Docker Compose
```bash
# Start MySQL
docker compose up mysql
# OR start PostgreSQL
docker compose up postgres
```

### Run the Application
Using Maven:
```bash
./mvnw spring-boot:run
```

Using Gradle:
```bash
./gradlew bootRun
```

Then visit: **http://localhost:8080**

---

## ☁️ Deploying to Azure

### 1. Provision Infrastructure
```bash
cd infra
terraform init
terraform plan -out tfplan
terraform apply tfplan
```

### 2. Deploy to Kubernetes
```bash
kubectl apply -f k8s/db/
kubectl apply -f k8s/petclinic/
```

---

## 🔄 CI/CD Pipeline (Jenkins)

The `Jenkinsfile` automates:

1. Checkout source  
2. Build & test (Maven/Gradle)  
3. Build Docker image & push to registry  
4. Terraform plan & apply (with manual approval)  
5. Deploy manifests to AKS  

---

## 🛠 Developer Environment (DevContainer)

This repo includes `.devcontainer/` so you can open it directly in **VS Code Remote Containers** with all tools preinstalled:
- Azure CLI
- Terraform
- kubectl
- Maven/Gradle
- Docker CLI

---

## 📜 License & Attribution

This project is licensed under the **Apache 2.0 License** (see `LICENSE.txt`).

It is **based on [Spring PetClinic](https://github.com/spring-projects/spring-petclinic)**, extended with DevOps automation (Terraform, Kubernetes, Jenkins, Docker).