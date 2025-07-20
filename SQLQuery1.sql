-- SCD TYPE 0: No changes are allowed to existing records.
CREATE PROCEDURE sp_scd_type_0
AS
BEGIN
    -- Insert only new records (ignore existing ones)
    INSERT INTO dim_customer (customer_id, name, address, phone)
    SELECT s.customer_id, s.name, s.address, s.phone
    FROM stg_customer s
    WHERE NOT EXISTS (
        SELECT 1 FROM dim_customer d WHERE d.customer_id = s.customer_id
    )
END
