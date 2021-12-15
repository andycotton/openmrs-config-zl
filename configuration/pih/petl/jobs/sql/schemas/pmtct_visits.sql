CREATE TABLE pmtct_visits (
    visit_id                    INT,
    encounter_id                INT,
    patient_id                  INT,
    visit_date                  DATE,
    health_facility             VARCHAR(100),
    hiv_test_date               DATE,
    -- hiv_test_result varchar(255),
    -- maternity_clinic_type varchar(100),
    index_asc                   INT,
    index_desc                  INT
);