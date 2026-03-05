
# Usage Guide – DataWave SQL Federation (Trino + Postgres + MySQL + Metabase)

This guide shows how to access the federation layer via **UI (Metabase)** and **CLI (Trino)**, and provides example SQL queries that demonstrate cross-source federation.

---

## 1 Access Methods

### A Federation UI (Metabase)
- URL: http://localhost:3001  
- Purpose: Run SQL queries via a UI editor, explore schemas, and visualize results.

**Connect Metabase to Trino**
1. Open Metabase → Admin/Settings → **Add database**
2. Choose **Starburst (Trino)**
3. Host: `trino`
4. Port: `8080`
5. Username: any (e.g., `dw`)
6. Save

> Tip: If a query fails in Metabase editor, try removing the trailing semicolon.

---

### B Federation CLI (Trino CLI inside container)
Run:
```bash
docker exec -it trino trino
````

You should see the prompt:
`trino>`

To exit:

```sql
exit;
```

---

## 2 Quick Validation Queries

### A Confirm Trino is running

```sql
SELECT 1;
```

### B See available catalogs (connectors)

```sql
SHOW CATALOGS;
```

Expected catalogs:

* `postgres`
* `mysql`
* `system`

### C List schemas and tables

**Postgres**

```sql
SHOW SCHEMAS FROM postgres;
SHOW TABLES FROM postgres.public;
```

**MySQL**

```sql
SHOW SCHEMAS FROM mysql;
SHOW TABLES FROM mysql.ops;
```

---

## 3 Example SQL Queries (Federation Proof)

### A Inspect source data

**Shipments from Postgres**

```sql
SELECT * FROM postgres.public.shipments ORDER BY shipment_id;
```

**Customers from MySQL**

```sql
SELECT * FROM mysql.ops.customers ORDER BY customer_id;
```

### B Cross-source JOIN (Postgres + MySQL)

This is the key federation proof: joining rows across two different systems in a single SQL query.

```sql
SELECT
  s.shipment_id,
  s.status,
  c.name AS customer_name,
  c.tier
FROM postgres.public.shipments s
JOIN mysql.ops.customers c
  ON s.customer_id = c.customer_id
ORDER BY s.shipment_id;
```

### C Filter + ORDER BY (federated)

```sql
SELECT
  s.shipment_id,
  s.origin,
  s.destination,
  c.name AS customer_name,
  c.tier
FROM postgres.public.shipments s
JOIN mysql.ops.customers c
  ON s.customer_id = c.customer_id
WHERE c.tier = 'GOLD'
ORDER BY s.shipment_id;
```

### D Aggregation by customer tier (federated)

```sql
SELECT
  c.tier,
  COUNT(*) AS shipment_count
FROM postgres.public.shipments s
JOIN mysql.ops.customers c
  ON s.customer_id = c.customer_id
GROUP BY c.tier
ORDER BY shipment_count DESC;
```

### E Status distribution (Postgres only)

```sql
SELECT status, COUNT(*) AS cnt
FROM postgres.public.shipments
GROUP BY status
ORDER BY cnt DESC;
```

### F Derived columns / CASE expression (federated)

```sql
SELECT
  s.shipment_id,
  c.name AS customer_name,
  s.status,
  CASE
    WHEN s.status = 'DELIVERED' THEN '✅'
    WHEN s.status = 'DELAYED' THEN '⚠️'
    ELSE '🚚'
  END AS status_flag
FROM postgres.public.shipments s
JOIN mysql.ops.customers c
  ON s.customer_id = c.customer_id
ORDER BY s.shipment_id;
```

---

## 4 How to Add a New Connector (Catalog) in Trino

Trino connectors are defined as **catalog files** in:
`trino/etc/catalog/`

### Steps

1. Create a new properties file:
   `trino/etc/catalog/<catalog-name>.properties`

2. Add connector config (example: another Postgres database)

```properties
connector.name=postgresql
connection-url=jdbc:postgresql://<host>:5432/<db>
connection-user=<user>
connection-password=<password>
```

3. Restart Trino:

```bash
docker compose restart trino
```

4. Verify the new catalog:

```sql
SHOW CATALOGS;
```

---

## 5 Troubleshooting

### A “Catalog not found” / “Schema not found”

* Confirm connector file exists under `trino/etc/catalog/`
* Restart Trino: `docker compose restart trino`
* Re-check: `SHOW CATALOGS;`

### B Metabase can’t connect to Trino

* Ensure Metabase points to host `trino` (not localhost) inside Docker network
* Confirm Trino is running: [http://localhost:8080]
* Check logs:

```bash
docker compose logs --tail 100 trino
docker compose logs --tail 100 metabase
```

### C SSO path (if enabled) fails

* Use: `http://localhost:8082`
* Check oauth2-proxy logs:

```bash
docker logs oauth2-proxy --tail 100
```

* Common Keycloak requirement: user email should be marked **Verified** if proxy enforces it.

```

