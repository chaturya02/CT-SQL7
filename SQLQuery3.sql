-- SCD TYPE 2: Keep full history by expiring old records and inserting new ones
CREATE PROCEDURE sp_scd_type_2
AS
BEGIN
    -- Mark old record as expired
    UPDATE dim_customer
    SET end_date = GETDATE(), is_current = 0
    FROM dim_customer d
    JOIN stg_customer s ON d.customer_id = s.customer_id
    WHERE d.is_current = 1 AND (
        d.name <> s.name OR d.address <> s.address OR d.phone <> s.phone
    );

    -- Insert new version of the record with current values
    INSERT INTO dim_customer (customer_id, name, address, phone, start_date, end_date, is_current)
    SELECT s.customer_id, s.name, s.address, s.phone, GETDATE(), NULL, 1
    FROM stg_customer s
    LEFT JOIN dim_customer d
        ON s.customer_id = d.customer_id AND d.is_current = 1
    WHERE d.customer_id IS NULL OR
          d.name <> s.name OR d.address <> s.address OR d.phone <> s.phone;
END
