CREATE TABLE diagnoses
(
    patient_id               int,
    dossierId                varchar(50),
    patient_primary_id       varchar(50),
    loc_registered           varchar(255),
    unknown_patient          varchar(50),
    gender                   varchar(50),
    age_at_encounter         int,
    department               varchar(255),
    commune                  varchar(255),
    section                  varchar(255),
    locality                 varchar(255),
    street_landmark          varchar(255),
    encounter_id             int,
    encounter_location       varchar(255),
    obs_id                   int,
    obs_datetime             datetime,
    entered_by               varchar(255),
    provider                 varchar(255),
    diagnosis_entered        text,
    dx_order                 varchar(255),
    certainty                varchar(255),
    coded                    varchar(255),
    diagnosis_concept        int,
    diagnosis_coded_fr       varchar(255),
    icd10_code               varchar(255),
    notifiable               int,
    urgent                   int,
    santeFamn                int,
    psychological            int,
    pediatric                int,
    outpatient               int,
    ncd                      int,
    non_diagnosis            int,
    ed                       int,
    age_restricted           int,
    oncology                 int,
    date_created             datetime,
    retrospective            int,
    visit_id                 int,
    birthdate                datetime,
    birthdate_estimated      bit,
    encounter_type           varchar(255),
    section_communale_CDC_ID varchar(11)
);