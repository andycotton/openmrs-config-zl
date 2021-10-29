CREATE TABLE datakind_patient_program${tableSuffix}
(
    patient_id     INT,
    program_name   VARCHAR(100),
    date_enrolled  DATETIME,
    date_completed DATETIME,
    outcome        VARCHAR(100),
    date_created   DATETIME,
    date_changed   DATETIME,
    site           VARCHAR(50),
    partition_num  INT
)
    ON psSite
(
    partition_num
);