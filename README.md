# DataWave SQL Federation (Docker Compose)

Local SQL federation stack : **Trino** as the federation engine, **PostgreSQL + MySQL** as source systems, and **Metabase** as the query UI. Includes optional **SSO** via **Keycloak + oauth2-proxy** to secure the federation engine UI/API.

---

## Architecture Overview :
<img width="3264" height="1764" alt="image" src="https://github.com/user-attachments/assets/1103f91b-33aa-4918-89f3-cbd3165a94a7" />


**Components**
- **Trino (Federation Engine)**: Single SQL endpoint that queries multiple backends via connectors/catalogs.  
  - Config: `trino/etc/*`  
  - Catalogs: `trino/etc/catalog/*.properties`
- **PostgreSQL (Source #1)**: Seeded shipments dataset.  
  - Seed: "postgres/init/01_init.sql"
- **MySQL (Source #2)**: Seeded customers dataset.  
  - Seed: "mysql/init/01_init.sql"
- **Metabase (UI)**: Runs queries against Trino via the “Starburst (Trino)” driver.  
  - UI: "http://localhost:3001" (mapped to container port 3000)
- **[Optional] Keycloak (SSO IdP)**: OIDC identity provider.  
  - Admin/UI: "http://localhost:8081"
- **[Optional] oauth2-proxy (SSO gateway)**: Protects Trino UI/API and enforces Keycloak login.  
  - Protected Trino entry: "http://localhost:8082"

**Interaction**
-> Users run SQL in **Metabase** → Metabase sends SQL to **Trino**.  
-> Trino federates queries to **Postgres** and **MySQL** via catalogs ("postgres", "mysql").  
-> Optional: Accessing Trino via "8082" requires Keycloak login, then oauth2-proxy forwards to "trino:8080".

---

## Setup Instructions

### Prerequisites
- Docker Desktop (Windows)
- Git

### Clone
```bash
git clone https://github.com/nilanjan-nandi2910/datawave-sql-federation.git
cd datawave-sql-federation
````

### Run in Powershell (Windows Machine)

```bash
docker compose up -d
docker compose ps
```

### Verify services

Open:

* Trino: [http://localhost:8080] (Direct URL)
* Metabase: [http://localhost:3001]

Trino Via SSO :

* Open [http://localhost:8082] → redirects to Keycloak [http://localhost:8081] → after login shows Trino UI.

* Email verified must be ON for Keycloak user for this to work

Check status/logs:

```bash
docker compose ps
docker compose logs --tail 50 trino
docker compose logs --tail 50 metabase
```

---

## Usage Guide:

### Trino CLI (To run SQL queries)

```bash
docker exec -it trino trino
```

### Example SQL Queries :

List catalogs:

```sql
SHOW CATALOGS
```

Postgres:

```sql
SHOW TABLES FROM postgres.public
SELECT * FROM postgres.public.shipments
```

MySQL:

```sql
SHOW TABLES FROM mysql.ops
SELECT * FROM mysql.ops.customers
```

Cross-source JOIN:

```sql
SELECT
  s.shipment_id,
  s.status,
  c.name AS customer_name,
  c.tier
FROM postgres.public.shipments s
JOIN mysql.ops.customers c
  ON s.customer_id = c.customer_id
ORDER BY s.shipment_id
```

### Metabase UI

1. Open [http://localhost:3001]
2. Add database → **Starburst (Trino)**

   * Host: "trino", Port: "8080", Username: any
3. Run the same queries above in the SQL editor

   * IMP Info: avoid trailing semicolons in Metabase editor.

### Add new connectors (Trino catalogs)

1. Add file: "trino/etc/catalog/<name>.properties"
2. Restart Trino:

```bash
docker compose restart trino
```

3. Verify:

```sql
SHOW CATALOGS
```

---

## SSO Documentation :

**Goal**: Secure access to federation engine UI/API ( Trino in this usecase)

**Flow**

1. User opens "http://localhost:8082"
2. oauth2-proxy redirects to Keycloak login (OIDC)
3. After successful login, oauth2-proxy creates a session and proxies requests to `http://trino:8080/`

**Keycloak configuration (summary)**

* Realm: `datawave`
* Client: `trino-proxy` (confidential)
* Redirect URI: `http://localhost:8082/oauth2/callback`
* Web origin: `http://localhost:8082`

**Verify**

* Open `http://localhost:8082` → redirected to Keycloak (`http://localhost:8081`) → after login Trino UI loads.

---

## Troubleshooting

### Port conflicts

* Metabase is exposed on **3001** (not 3000).

### Reset everything

```bash
docker compose down -v
docker compose up -d
```

---

## Project Structure

* "docker-compose.yml"
* "trino/etc/*" (config + catalogs)
* "postgres/init/*" (seed SQL)
* "mysql/init/*" (seed SQL)
* "screenshots/*" (proof screenshots)

```
```
