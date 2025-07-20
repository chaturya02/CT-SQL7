-- SCD TYPE 1: Overwrite existing data (no history maintained)
CREATE PROCEDURE sp_scd_type_1
AS
BEGIN
    MERGE dim_customer AS target
    USING stg_customer AS source
    ON target.customer_id = source.customer_id
    WHEN MATCHED THEN
        -- Update the existing record with new values
        UPDATE SET
            target.name = source.name,
            target.address = source.address,
            target.phone = source.phone
    WHEN NOT MATCHED THEN
        -- Insert new records
        INSERT (customer_id, name, address, phone)
        VALUES (source.customer_id, source.name, source.address, source.phone);
END
