# Parking Management System (V11.0)

A modular, dockerized Full-Stack solution for high-efficiency parking management.

## 🚀 Overview

This system manages everything from physical station status (simulated via sensors/mock data) to complex subscriber billing and technical debt tracking.

### Key Features

- **Real-time Monitoring**: Visual dashboard with "Traffic Light" status for every parking spot.
- **Subscriber Portal**: Landing page for benefits and automated registration with doc upload.
- **Smart Billing**: Automatic monthly invoice generation for subscribers via direct debit.
- **BI Layer**: Advanced views for occupancy heatmaps, efficiency, and debt tracking.

## 🏗️ Architecture

- **Backend**: Java 17 (Spring Boot 3) + Spring Data JPA.
- **Frontend**: React (Next.js 14) + Tailwind CSS.
- **Database**: PostgreSQL 15 (Modular schema).
- **Infrastrucutre**: Docker & Docker Compose.

## 🛠️ Local Setup

1. **Clone the repository**:

   ```bash
   git clone https://github.com/jmrs9206/sistemaParkings.git
   cd gestionParkings
   ```

2. **Start the stack**:

   ```bash
   docker-compose up --build -d
   ```

3. **Access the application**:
   - **Frontend**: [http://localhost:9000](http://localhost:9000)
   - **Backend API**: [http://localhost:7070/api](http://localhost:7070/api)
   - **Database**: `localhost:5432` (Credentials in `docker-compose.yml`)

## 🚢 Server Deployment

To deploy on a production server:

1. Ensure **Docker** and **Docker Compose** are installed.
2. Copy the project folder to the server.
3. Configure your production environment variables in a `.env` file (Database passwords, API keys).
4. Run:
   ```bash
   docker-compose up -d
   ```
5. (Recommended) Set up an Nginx reverse proxy to handle SSL (HTTPS) and route traffic to ports 3000 and 8080.

## 📁 Project Structure

```text
gestionParkings/
├── backend/            # Java REST API
├── frontend/           # Next.js Presentation Layer
├── database/           # Modular SQL Scripts
└── docker-compose.yml  # System Orchestration
```

---

_Developed by JMRS_
