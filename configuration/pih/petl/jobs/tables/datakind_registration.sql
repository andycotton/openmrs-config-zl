CREATE TABLE datakind_registration${tableSuffix}
(
    patient_id             INT,
    registration_date      DATETIME,
    death_date             DATETIME,
    patient_date_created   DATETIME,
    patient_date_changed   DATETIME,
    encouter_date_created  DATETIME,
    encounter_date_changed DATETIME,
    site                   VARCHAR(50),
    partition_num          INT
)
    ON psSite
(
    partition_num
);