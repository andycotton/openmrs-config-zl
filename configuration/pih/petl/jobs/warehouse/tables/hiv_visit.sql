CREATE TABLE hiv_visit${tableSuffix}
(
    encounter_id    INT,
    patient_id      INT,
    emr_id          VARCHAR(25),
    pregnant        BIT,
    visit_date      DATE,
    next_visit_date DATE,
    code_site       INT,
    site            VARCHAR(50),
    partition_num   INT
)
    ON psSite
(
    partition_num
);