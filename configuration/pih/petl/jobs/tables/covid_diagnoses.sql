CREATE TABLE covid_diagnoses${tableSuffix}
(
    patient_id             INT,
    encounter_id           INT,
    encounter_type         VARCHAR(255),
    location               TEXT,
    encounter_date         DATE,
    diagnosis_order        TEXT,
    diagnosis              TEXT,
    diagnosis_confirmation TEXT,
    covid19_diagnosis      VARCHAR(255),
    site                   VARCHAR(50),
    partition_num          INT
) ON psSite
(
    partition_num
);