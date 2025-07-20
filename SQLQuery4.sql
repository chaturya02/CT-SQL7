-- SCD TYPE 3: Track limited history in the same row (e.g., previous address)
CREATE PROCEDURE sp_scd_type_3
AS
BEGIN
    -- Update current record and shift previous values
    UPDATE dim_customer
    SET prev_address = address,
        prev_phone = phone,
        address = s.address,
        phone = s.phone
    FROM dim_customer d
    JOIN stg_customer s ON d.customer_id = s.customer_id
    WHERE d.address <> s.address OR d.phone <> s.phone;

    -- Insert new customers only
    INSERT INTO dim_customer (customer_id, name, address, phone)
    SELECT customer_id, name, address, phone
    FROM stg_customer s
    WHERE NOT EXISTS (
        SELECT 1 FROM dim_customer d WHERE d.customer_id = s.customer_id
    );
END
