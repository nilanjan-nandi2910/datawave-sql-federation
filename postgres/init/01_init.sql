CREATE TABLE IF NOT EXISTS public.shipments (
  shipment_id   VARCHAR(20) PRIMARY KEY,
  customer_id   VARCHAR(20) NOT NULL,
  origin        VARCHAR(50),
  destination   VARCHAR(50),
  status        VARCHAR(20),
  updated_at    TIMESTAMP DEFAULT NOW()
);

INSERT INTO public.shipments (shipment_id, customer_id, origin, destination, status)
VALUES
  ('SHP001','CUST01','Bangalore','Mumbai','IN_TRANSIT'),
  ('SHP002','CUST02','Delhi','Chennai','DELIVERED'),
  ('SHP003','CUST01','Pune','Kolkata','DELAYED')
ON CONFLICT (shipment_id) DO NOTHING;