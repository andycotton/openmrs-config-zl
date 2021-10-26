CREATE TABLE covid_disposition${tableSuffix}
(
    patient_id          INT,
    encounter_id        INT,
    encounter_type      VARCHAR(255),
    location            TEXT,
    encounter_date      DATE,
    disposition         VARCHAR(255),
    discharge_condition VARCHAR(255),
    index_asc           INT,
    index_desc          INT,
    site                VARCHAR(50),
    partition_num       INT
)
    ON psSite
(
    partition_num
);