-- SCD TYPE 6: Combination of Type 1, 2, and 3
-- Track full history, store previous value, and update current record

CREATE PROCEDURE sp_scd_type_6
AS
BEGIN
    -- Expire current version
    UPDATE dim_customer
    SET end_date = GETDATE(), is_current = 0
    FROM dim_customer d
    JOIN stg_customer s ON d.customer_id = s.customer_id
    WHERE d.is_current = 1 AND (
        d.name <> s.name OR d.address <> s.address OR d.phone <> s.phone
    );

    -- Insert new record with current values and save previous address
    INSERT INTO dim_customer (customer_id, name, address, prev_address, phone, start_date, end_date, is_current)
    SELECT
        s.customer_id,
        s.name,
        s.address,
        d.address AS prev_address,
        s.phone,
        GETDATE(), NULL, 1
    FROM stg_customer s
    JOIN dim_customer d ON s.customer_id = d.customer_id AND d.is_current = 0
    WHERE d.customer_id NOT IN (
        SELECT customer_id FROM dim_customer WHERE is_current = 1
    );
    
    -- Insert completely new customers
    INSERT INTO dim_customer (customer_id, name, address, phone, start_date, end_date, is_current)
    SELECT s.customer_id, s.name, s.address, s.phone, GETDATE(), NULL, 1
    FROM stg_customer s
    WHERE NOT EXISTS (
        SELECT 1 FROM dim_customer d WHERE d.customer_id = s.customer_id
    );
END
