SET sqL_safe_updates = 0;

SET @initial_pmtct_encounter = ENCOUNTER_TYPE('584124b9-1f10-4757-ba09-91fc9075af92');
SET @followup_pmtct_encounter =  ENCOUNTER_TYPE('95e03e7d-9aeb-4a99-bd7a-94e8591ec2c5');

-- drop and create temp pmct visit table
DROP TEMPORARY TABLE IF EXISTS temp_pmtct_visit;
CREATE TEMPORARY TABLE temp_pmtct_visit (
    visit_id                INT,
    encounter_id            INT,
    patient_id              INT,
    visit_date              DATE,
    health_facility         VARCHAR(100),
    hiv_test_date           DATE,
    -- hiv_test_result varchar(255),
    -- maternity_clinic_type varchar(100),
    index_asc               INT,
    index_desc              INT
);

INSERT INTO temp_pmtct_visit (visit_id, encounter_id, patient_id)
SELECT visit_id, encounter_id, patient_id FROM encounter WHERE encounter_type IN (@initial_pmtct_encounter, @followup_pmtct_encounter) AND voided = 0;

-- visit date
UPDATE temp_pmtct_visit t SET t.visit_date = VISIT_DATE(t.encounter_id);

-- facility where healthcare is recieved
 UPDATE temp_pmtct_visit t SET t.health_facility = ENCOUNTER_LOCATION_NAME(t.encounter_id);
 
-- Hiv test date
UPDATE  temp_pmtct_visit t SET hiv_test_date = OBS_VALUE_DATETIME(t.encounter_id, 'PIH', 'HIV TEST DATE');

-- index asc
DROP TEMPORARY TABLE IF EXISTS temp_pmtct_visit_index_asc;
CREATE TEMPORARY TABLE temp_pmtct_visit_index_asc
(
    SELECT
            visit_id,
            encounter_id,
            patient_id,
			index_asc
    FROM (SELECT
            @r:= IF(@u = patient_id, @r + 1,1) index_asc,
            visit_id,
            encounter_id,
            patient_id,
            @u:= patient_id
      FROM temp_pmtct_visit,
            (SELECT @r:= 1) AS r,
            (SELECT @u:= 0) AS u
      ORDER BY patient_id, visit_id ASC
        ) index_ascending );

-- index desc
DROP TEMPORARY TABLE IF EXISTS temp_pmtct_visit_index_desc;
CREATE TEMPORARY TABLE temp_pmtct_visit_index_desc
(
    SELECT
            visit_id,
            encounter_id,
            patient_id,
			index_desc
    FROM (SELECT
            @r:= IF(@u = patient_id, @r + 1,1) index_desc,
            visit_id,
            encounter_id,
            patient_id,
            @u:= patient_id
      FROM temp_pmtct_visit,
            (SELECT @r:= 1) AS r,
            (SELECT @u:= 0) AS u
      ORDER BY patient_id, visit_id DESC
        ) index_descending );
 
UPDATE temp_pmtct_visit t SET t.index_asc = (SELECT index_asc FROM temp_pmtct_visit_index_asc a WHERE t.visit_id = a.visit_id);
UPDATE temp_pmtct_visit t SET t.index_desc = (SELECT index_desc FROM temp_pmtct_visit_index_desc b WHERE t.visit_id = b.visit_id);

SELECT * FROM temp_pmtct_visit ORDER BY patient_id, visit_id;