CREATE TABLE IF NOT EXISTS customers (
  customer_id VARCHAR(20) PRIMARY KEY,
  name        VARCHAR(100),
  tier        VARCHAR(20),
  country     VARCHAR(50)
);

INSERT INTO customers (customer_id, name, tier, country)
VALUES
  ('CUST01','Acme Logistics','GOLD','India'),
  ('CUST02','Globex Supply','SILVER','India')
ON DUPLICATE KEY UPDATE name=VALUES(name);