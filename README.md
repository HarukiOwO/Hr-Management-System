# 🏢 HR Management System (HRMS) — Enterprise Production Deployment

[![Spring Boot](https://img.shields.io/badge/Spring_Boot_3.2-%236DB33F.svg?style=for-the-badge&logo=spring-boot&logoColor=white)](https://spring.io/projects/spring-boot)
[![Java 17](https://img.shields.io/badge/Java_17-%23ED8B00.svg?style=for-the-badge&logo=openjdk&logoColor=white)](https://adoptium.net/)
[![Next.js 16](https://img.shields.io/badge/Next.js_16_(Turbopack)-black?style=for-the-badge&logo=next.js&logoColor=white)](https://nextjs.org/)
[![React 19](https://img.shields.io/badge/React_19-%2320232a.svg?style=for-the-badge&logo=react&logoColor=%2361DAFB)](https://react.dev/)
[![TiDB Cloud Serverless MySQL](https://img.shields.io/badge/TiDB_Cloud_Serverless_MySQL-%234479A1.svg?style=for-the-badge&logo=mysql&logoColor=white)](https://tidbcloud.com/)
[![Docker Compose v2](https://img.shields.io/badge/Docker_Compose_v2-2496ED?style=for-the-badge&logo=docker&logoColor=white)](https://www.docker.com/)
[![AWS CloudFront + S3 + EC2](https://img.shields.io/badge/AWS_CloudFront_|_S3_|_EC2-%23FF9900.svg?style=for-the-badge&logo=amazon-aws&logoColor=white)](https://aws.amazon.com/)

A state-of-the-art, cloud-native **Enterprise Human Resource Management System (HRMS)** engineered for high performance, zero-trust security, and maximum cost efficiency (**~$19.67/mo AWS Target Architecture**).

> **Full Documentation Suite:** For comprehensive details on sequence diagrams, networking protocols, state management, and Terraform automation, see **[DOCUMENTATION.md](DOCUMENTATION.md)**.

---

## 🏛️ Live Production Architecture & Deployment

The system is deployed using our **Option 2 Architecture Pattern (CloudFront CDN Edge with `/api/*` HTTPS Reverse Proxy to EC2 Nginx + Spring Boot + TiDB Cloud Serverless MySQL)**:

```mermaid
graph TD
    subgraph Global Edge / Clients
        Client[Browser / User Device]
    end

    subgraph AWS CloudFront CDN Edge (E2QCPRK45LRQB2)
        CDN["https://d2cloh163xljkh.cloudfront.net<br/>(HTTPS Edge SSL Certificate)"]
    end

    subgraph AWS S3 Static Storage
        S3["s3://hr-management-system-frontend-64fqj6pp<br/>(Next.js 16 Static HTML / JS Export)"]
    end

    subgraph AWS EC2 t3.small Instance (32.193.50.120)
        subgraph Docker Bridge Network: hrms_network
            Nginx["hrms-nginx (Port 80)<br/>Reverse Proxy + CORS"]
            SpringBoot["hrms-backend (Port 8080)<br/>Spring Boot 3.2.5 REST API"]
        end
    end

    subgraph TiDB Cloud Serverless MySQL Cluster
        TiDB[("gateway01.us-east-1.prod.aws.tidbcloud.com:4000<br/>MySQL 8.0 Database ($0/mo Free Tier)")]
    end

    Client -- "HTTPS Requests" --> CDN
    CDN -- "Default Route (/)" --> S3
    CDN -- "Ordered Behavior (/api/*)" --> Nginx
    Nginx -- "proxy_pass http://backend:8080" --> SpringBoot
    SpringBoot -- "Hibernate JPA Connection" --> TiDB
```

### ⚡ Live Production Endpoints
* **Frontend Portal (HTTPS CDN):** 👉 **`https://d2cloh163xljkh.cloudfront.net`**
* **Backend Reverse Proxy IP:** **`http://32.193.50.120`** *(Proxied automatically by CloudFront via `/api/*`)*
* **Database Cluster:** **`gateway01.us-east-1.prod.aws.tidbcloud.com:4000`** *(TiDB Cloud Serverless MySQL)*

---

## 🔐 Default Pre-Seeded Accounts (`DataSeeder`)

When `hrms-backend` initializes, `DataSeeder.java` connects to TiDB and auto-creates the schema (`14 tables`) along with three production-ready accounts:

| Portal Area | Email | Password | Role | Access Capabilities |
| :--- | :--- | :--- | :--- | :--- |
| **Admin Login** | `admin@hrms.com` | `Admin@123` | `ADMIN` | Full administrative control, payroll generation, settings, user management |
| **Admin Login** | `hr@hrms.com` | `Hr@12345` | `HR` | Recruitment pipelines, onboarding checklists, employee profiles, attendance logs |
| **Employee Login** | `emp@hrms.com` | `Emp@12345` | `EMPLOYEE` | Self-service attendance clocking, leave requests, historical payslips |

---

## 🗂️ Project Repository Structure

```
Hr-Management-System/
├── .env                              # Root local development environment configuration
├── .env.sample                       # Root template for local & cloud environment variables
├── docker-compose-test.yml           # Local multi-container stack (Spring Boot + Local MySQL container)
├── docker-compose.prod.yml           # Production AWS EC2 stack (Nginx Alpine + Spring Boot connected to TiDB)
├── DOCUMENTATION.md                  # Detailed architectural & infrastructure reference
├── backend/hrms/                     # Spring Boot 3.2.5 REST API Backend (Java 17, JWT, Hibernate JPA)
│   ├── Dockerfile                    # Multi-stage Docker build (Maven compile -> Alpine JRE 17 runner)
│   └── src/main/resources/           # Configuration & database migrations
├── frontend/                         # Next.js 16 / React 19 Web Application (`output: export`)
│   ├── .env.production               # Production configuration (`NEXT_PUBLIC_API_BASE_URL=https://...`)
│   ├── .env.production.sample        # Sample production environment configuration
│   └── Dockerfile                    # Multi-stage standalone build support
├── infrastructure/terraform/         # Automated Infrastructure as Code (VPC, EC2, S3, CloudFront, EIP)
│   ├── s3-cloudfront.tf              # CloudFront CDN edge distribution with `/api/*` reverse proxy
│   └── Scripts/                      # Automated server bootstrap (`installDocker.sh`, `app-server-setup.sh`)
└── nginx/                            # Nginx reverse proxy configurations
    └── nginx.conf                    # Production CORS & upstream proxy configuration
```

---

## 🛠️ Local Development & Quick Start Guide

If you wish to run or modify the application locally on your PC (Windows / macOS / Linux):

### 1. Root `.env` Configuration
Copy the sample environment template:
```powershell
Copy-Item .env.sample .env
```

### 2. Run Local Stack (`Spring Boot + Local MySQL Container`)
To boot up the backend using Docker:
```powershell
docker compose -f docker-compose-test.yml up -d --build
```

### 3. Run Frontend Locally (`Next.js Turbopack`)
Open a new terminal inside `frontend/` and launch the local development server:
```powershell
cd frontend
npm install
npm run dev
```
* **Frontend Web UI:** [http://localhost:3000](http://localhost:3000)
* **Local Backend API:** [http://localhost:8080](http://localhost:8080)

---

## ☁️ Production Deployment Workflow (`AWS EC2 + S3 + CloudFront`)

Whenever you make updates to the code and want to deploy to your live AWS cloud infrastructure:

### 1. Update Backend on AWS EC2 (`32.193.50.120`)
SSH into your EC2 server (`ip-10-0-1-69`) and run:
```bash
git pull origin dev
docker compose -f docker-compose.prod.yml up -d --build
```

### 2. Update Frontend on AWS S3 + CloudFront CDN
Open PowerShell inside `frontend/` on your development machine:
```powershell
cd d:\Hr-Management-System\frontend
Remove-Item -Recurse -Force .next, out -ErrorAction SilentlyContinue
npm run build
aws s3 sync ./out s3://hr-management-system-frontend-64fqj6pp/ --delete
aws cloudfront create-invalidation --distribution-id E2QCPRK45LRQB2 --paths "/*"
```
Once the invalidation completes (`~10 seconds`), your global CDN link **`https://d2cloh163xljkh.cloudfront.net`** will serve your latest updates instantly over HTTPS!

---

## 📜 Further Reading & Module Documentation
* **Architectural Deep Dive:** [DOCUMENTATION.md](DOCUMENTATION.md)
* **Backend API & Controllers:** [backend/hrms/README.md](backend/hrms/README.md)
* **Frontend Portal & Redux Store:** [frontend/README.md](frontend/README.md)
