# DataWave SQL Federation Architecture (Local Docker Compose)

This repo implements a local SQL Federation Layer using **Trino** (SQL federation engine) over **PostgreSQL** and **MySQL**, with **Metabase** as the UI to run queries and visualize results.

## Architecture
- **Trino**: federation/query layer (single SQL endpoint)
- **PostgreSQL**: source system #1 (shipments)
- **MySQL**: source system #2 (customers)
- **Metabase**: UI for querying Trino

## Prerequisites
- Docker Desktop (Windows)
- Git

## Run
```bash
docker compose up -d
docker compose ps# datawave-sql-federation
