CREATE TABLE mch_birth${tableSuffix}
(
    patient_id                   INT,
    mother_emr_id                VARCHAR(25),
    encounter_date               DATE,
    birth_number                 INT,
    multiples                    INT,
    birth_apgar                  INT,
    birth_outcome                VARCHAR(30),
    birth_weight                 FLOAT,
    birth_neonatal_resuscitation VARCHAR(5),
    birth_macerated_fetus        VARCHAR(5),
    site                         VARCHAR(50),
    partition_num                INT
)
    ON psSite
(
    partition_num
);