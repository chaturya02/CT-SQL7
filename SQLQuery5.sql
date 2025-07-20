-- SCD TYPE 4: Maintain history in a separate history table
CREATE PROCEDURE sp_scd_type_4
AS
BEGIN
    -- Archive the old version to history table
    INSERT INTO dim_customer_history (customer_id, name, address, phone, change_date)
    SELECT d.customer_id, d.name, d.address, d.phone, GETDATE()
    FROM dim_customer d
    JOIN stg_customer s ON d.customer_id = s.customer_id
    WHERE d.name <> s.name OR d.address <> s.address OR d.phone <> s.phone;

    -- Update current version in main table
    UPDATE d
    SET name = s.name,
        address = s.address,
        phone = s.phone
    FROM dim_customer d
    JOIN stg_customer s ON d.customer_id = s.customer_id;

    -- Insert brand new customers
    INSERT INTO dim_customer (customer_id, name, address, phone)
    SELECT customer_id, name, address, phone
    FROM stg_customer s
    WHERE NOT EXISTS (
        SELECT 1 FROM dim_customer d WHERE d.customer_id = s.customer_id
    );
END
