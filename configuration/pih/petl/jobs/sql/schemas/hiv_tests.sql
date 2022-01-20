CREATE TABLE hiv_tests (
    person_id                   INT,
    emr_id                      VARCHAR(25),
    encounter_id                INT,
    specimen_collection_date    DATE,
    result_date                 DATE,
    concept_name                VARCHAR(100),
    value_coded                 VARCHAR(255),
    index_asc                   INT,
    index_desc                  INT
);