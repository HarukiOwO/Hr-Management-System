# 🏢 HR Management System (HRMS)

A modern, full-stack Human Resource Management System built with **Spring Boot 3 + MySQL** (Backend), **Next.js + React** (Frontend), and **Terraform/Docker** (Infrastructure & AWS Deployment).

---

## 🗂️ Project Structure

```
Hr-Management-System/
├── backend/hrms/           # Spring Boot 3.2.5 REST API Backend (Java 17, JWT, OpenAPI/Swagger)
├── frontend/hrms-web/      # Next.js / React Web Application
└── infrastructure/         # AWS Deployment Guides, DevOps Architecture & Terraform scripts
```

---

## 🚀 Quick Start Guide

### 1️⃣ Backend Setup & Running
Navigate to the `backend/hrms` directory:
```bash
cd backend/hrms
```

#### Option A: Run Locally with Zero Setup (H2 Embedded DB)
By default, the backend runs using a self-contained H2 embedded database in **MySQL compatibility mode (`MODE=MySQL`)**. No external database installation is required!
```bash
mvn spring-boot:run
```
* **API Documentation (Swagger UI):** `http://localhost:8080/swagger-ui.html`
* **H2 Database Console:** `http://localhost:8080/h2-console` (`JDBC URL: jdbc:h2:file:./data/hrms_db`, User: `sa`, Password: empty)

#### Option B: Run with MySQL Server
If you prefer running against a live MySQL server (`localhost:3306`):
1. In `backend/hrms/src/main/resources/application.properties`, comment out `# spring.profiles.active=local`.
2. Ensure MySQL is running with database `hrms_db` (`root` / `your_db_password`), or spin one up using Docker with an environment variable placeholder:
   ```bash
   docker run --name hrms-mysql -p 3306:3306 -e MYSQL_DATABASE=hrms_db -e MYSQL_ROOT_PASSWORD=${DB_PASSWORD:-change_me_in_env} -d mysql:8.0
   ```
3. Run the application:
   ```bash
   mvn spring-boot:run
   ```

> 📖 For full details on database schema, API endpoints, and AWS Container Deployment (`Amazon ECR/ECS + RDS`), please see the detailed [Backend README](file:///d:/Hr-Management-System/backend/hrms/README.md).

---

## 👤 Pre-Seeded Default Accounts

When the application boots for the first time, it automatically seeds three default test accounts:

| Role | Email | Password | Login Portal (`loginType`) |
|------|-------|----------|---------------------------|
| **ADMIN** | `admin@hrms.com` | `Admin@123` | `ADMIN` |
| **HR** | `hr@hrms.com` | `Hr@12345` | `ADMIN` |
| **EMPLOYEE** | `emp@hrms.com` | `Emp@12345` | `EMPLOYEE` |

---

## ☁️ AWS Deployment Overview
This project is built for cloud-native containerized deployment:
* **Backend Image:** Built via multi-stage [Dockerfile](file:///d:/Hr-Management-System/backend/hrms/Dockerfile). Stage 1 (`AS build`) compiles the JAR file using Maven, and Stage 2 runs it on a lightweight Alpine JRE 17 container using a non-root security profile (`hrmsuser`).
* **Cloud Database:** Connects to **Amazon RDS MySQL 8.0** in production by setting `SPRING_DATASOURCE_URL`, `SPRING_DATASOURCE_USERNAME`, and `SPRING_DATASOURCE_PASSWORD` environment variables in your AWS ECS/EC2 container definition.
