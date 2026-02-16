# Phoenix Parking System (V13.3)

A modular, dockerized Full-Stack solution for high-efficiency parking management.

## 🚀 Overview

The **Phoenix Parking** system manages everything from physical station status (simulated via sensors/mock data) to complex subscriber billing and technical debt tracking.

### Key Features

- **Ultra-Premium Dashboard**: Visual maps and real-time metrics for staff.
- **Subscriber Portal**: Specialized interface for invoice management and contract details.
- **Dynamic Access Control**: Role-based views (Public, Subscriber, Staff).
- **Automation**: Automatic license plate recognition and billing simulation.

## 🏗️ Architecture

- **Backend**: Java 17 (Spring Boot 3) - Standalone POJO architecture.
- **Frontend**: HTML5, CSS3, JS Vanilla (Static Web App).
- **Database**: PostgreSQL 15 (Port 5433).

## 🛠️ Local Setup

### 1. Database (Docker)

Ensure Docker is running and start the database:

```bash
docker compose up parking-db -d
```

_Note: DB is mapped to port **5433**._

### 2. Frontend (Static HTML/JS)

Simply open the `index.html` file in your browser:

```bash
# Open directly (may have CORS/MPA issues)
firefox frontend/index.html

# RECOMMENDED: Use a simple server on port 3002
cd frontend
python3 -m http.server 3002
# Then go to http://localhost:3002
```

### 3. Backend (Java / Spring Boot)

If Docker network issues persist, run locally:

1. **Install Maven**:
   ```bash
   sudo apt update && sudo apt install -y maven
   ```
2. **Run Server**:
   ```bash
   cd backend
   mvn spring-boot:run
   ```
   _API accessible at: [http://localhost:8080](http://localhost:8080)_

## 📁 Project Structure

```text
gestionParkings/
├── backend/            # Java REST API (Spring Boot)
├── frontend/           # Static Web App (HTML/CSS/JS)
├── database/           # SQL Modular Schema & DML
└── docker-compose.yml  # Orchestration (DB: 5433)
```

---

_Developed by JMRS - Powered by Phoenix_
