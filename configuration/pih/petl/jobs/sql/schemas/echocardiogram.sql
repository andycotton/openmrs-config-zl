CREATE TABLE echocardiogram_encounters
(
    patient_id                           INT,
    dossierId                            VARCHAR(30),
    emrid                                VARCHAR(30),
    age                                  FLOAT,
    gender                               VARCHAR(10),
    loc_registered                       VARCHAR(255),
    date_echocardiogram                  DATETIME,
    encounter_location                   VARCHAR(255),
    provider                             VARCHAR(255),
    encounter_id                         INT,
    visit_id                             INT,
    systolic_bp                          FLOAT,
    diastolic_bp                         FLOAT,
    heart_rate                           FLOAT,
    murmur                               VARCHAR(255),
    NYHA_class                           VARCHAR(255),
    left_ventricle_systolic_function     VARCHAR(255),
    right_ventricle_dimension            VARCHAR(255),
    mitral_valve                         VARCHAR(255),
    pericardium                          VARCHAR(255),
    inferior_vena_cava                   VARCHAR(255),
    left_ventricle_dimension             VARCHAR(255),
    pulmonary_artery_systolic_pressure   FLOAT,
    disease_category                     VARCHAR(255),
    disease_category_other_comment       TEXT,
    peripartum_cardiomyopathy_diagnosis  BIT,
    ischemic_cardiomyopathy_diagnosis    BIT,
    study_results_changed_treatment_plan BIT,
    general_comments                     TEXT,
    encounter_date_created               DATETIME,
    index_asc                            INT,
    index_desc                           INT
);