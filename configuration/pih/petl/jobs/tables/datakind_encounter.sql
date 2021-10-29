CREATE TABLE datakind_encounter${tableSuffix}
(
    patient_id         INT,
    encounter_id       INT,
    encounter_datetime DATETIME,
    encounter_type     VARCHAR(255),
    encounter_location TEXT,
    provider           VARCHAR(255),
    data_entry_clerk   VARCHAR(255),
    date_entered       DATETIME,
    date_changed       DATETIME,
    obs_count          INT,
    index_asc          INT,
    index_desc         INT,
    site               VARCHAR(50),
    partition_num      INT
)
    ON psSite
(
    partition_num
);