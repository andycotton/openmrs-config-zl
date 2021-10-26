create table hiv_patient_program${tableSuffix}
(
    patient_program_id INT,
    patient_id         INT,
    date_enrolled      DATE,
    date_completed     DATE,
    location           VARCHAR(255),
    outcome            VARCHAR(255),
    site               VARCHAR(50),
    partition_num      INT
)
    ON psSite
(
    partition_num
);