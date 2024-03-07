SET sql_safe_updates = 0;
SET @partition = '${partitionNum}';
SET @locale = GLOBAL_PROPERTY_VALUE('default_locale', 'en');

SET @obgyn_encounter = (SELECT encounter_type_id FROM encounter_type WHERE uuid = 'd83e98fd-dc7b-420f-aa3f-36f648b4483d');

DROP TEMPORARY TABLE IF EXISTS temp_obgyn_visit;
CREATE TEMPORARY TABLE temp_obgyn_visit
(
encounter_id    int(11),
encounter_datetime datetime,
visit_id        int(11),
vitals_encounter_id int(11),
patient_id      int(11),
dossier_id      varchar(50),
first_name      varchar(50),
last_name      varchar(50),
mothers_first_name varchar(50),
date_of_birth datetime,
age_at_encounter double,
address text,
date_of_last_menstrual_period datetime,
gestational_age int,
estimated_delivery_date datetime,
gravida int,
parity int,
abortus int, 
living_children int,
referral_source varchar(255),
visit_count int,
visit_date datetime,
anti_tetanus_vaccination datetime,
high_risks_for_the_pregnancy text,
hiv_test_obs_id_labs int(11), -- HIV stuff
hiv_test_encounter_id_labs int(11),
hiv_test_date_labs datetime,
hiv_test_result_date_labs datetime,
result_labs varchar(255),
hiv_test_date_form datetime,
result_form varchar(255),
hiv_test_date datetime,
hiv_test_result_date datetime,
result varchar(255),
not_tested_for_hiv boolean,
syphillis_details_not_tracked_in_emr varchar(50),
syphiliss_treatment_start_date datetime,
syphillis_treatment_end_date datetime,
on_art_for_hiv_prior_to_pregnancy boolean,
additional_hiv_details_not_in_the_emr varchar(50),
height_in_m double,
upper_arm_circumference double,
malnutrition_malaria_details_not_in_emr  varchar(50),
malnutrition varchar(255),
iron_deficiency_anemia boolean,
malaria boolean,
birth_plan boolean,
accepts_accompanateur boolean,
enrolled_in_mother_support_group boolean
);

INSERT INTO temp_obgyn_visit(patient_id, encounter_id,encounter_datetime, visit_id)
SELECT DISTINCT e.patient_id, e.encounter_id, e.encounter_datetime, visit_id 
FROM encounter e
INNER JOIN obs o ON o.encounter_id = e.encounter_id AND o.voided = 0 -- ensure that only rows with obs are included
WHERE e.voided = 0 AND encounter_type = @obgyn_encounter
AND ((date(e.encounter_datetime) >=@startDate) or @startDate is null)
AND ((date(e.encounter_datetime) <=@endDate)  or @endDate is null);

CREATE INDEX temp_obgyn_visit_patient_id ON temp_obgyn_visit (patient_id);
CREATE INDEX temp_obgyn_visit_encounter_id ON temp_obgyn_visit (encounter_id);

-- patient level columns
DROP TEMPORARY TABLE IF EXISTS temp_patient_level;
CREATE TEMPORARY TABLE temp_patient_level
(
patient_id int(11),
dossier_id      VARCHAR(50),
first_name      VARCHAR(50),
last_name      VARCHAR(50),
mothers_first_name VARCHAR(50),
date_of_birth datetime,
address text
);

insert into temp_patient_level (patient_id)
select distinct patient_id from temp_obgyn_visit;

update temp_patient_level t 
set t.mothers_first_name = person_attribute_value(patient_id, 'First Name of Mother');

update temp_patient_level t 
set t.dossier_id = dosId(t.patient_id);

update temp_patient_level t 
set t.first_name = person_given_name(t.patient_id);

update temp_patient_level t 
set t.last_name = person_family_name(t.patient_id);

update temp_patient_level t 
set t.date_of_birth = birthdate(t.patient_id);

update temp_patient_level t 
set t.address = person_address(t.patient_id);

update temp_obgyn_visit v
inner join temp_patient_level t on t.patient_id = v.patient_id
set v.dossier_id = t.dossier_id,
v.first_name = t.first_name,
v.last_name = t.last_name,
v.mothers_first_name = t.mothers_first_name,
v.date_of_birth = t.date_of_birth,
v.address = t.address;

DROP TEMPORARY TABLE IF EXISTS temp_obs;
CREATE TEMPORARY TABLE temp_obs 
SELECT o.obs_id, o.voided ,o.obs_group_id , o.encounter_id, o.person_id, o.concept_id, o.value_coded, o.value_numeric, o.value_text,o.value_datetime, o.comments , o.date_created
FROM obs o
INNER JOIN temp_obgyn_visit t ON t.encounter_id = o.encounter_id
WHERE o.voided = 0;

CREATE INDEX temp_mch_obs_concept_id ON temp_obs(concept_id);
CREATE INDEX temp_mch_obs_ei ON temp_obs(encounter_id);

UPDATE temp_obgyn_visit te 
set age_at_encounter = age_at_enc(te.patient_id, te.encounter_id);	

UPDATE temp_obgyn_visit te 
set date_of_last_menstrual_period = obs_value_datetime_from_temp(te.encounter_id,'PIH', 'DATE OF LAST MENSTRUAL PERIOD');

UPDATE temp_obgyn_visit te 
set gestational_age =ROUND(DATEDIFF(te.encounter_datetime, te.date_of_last_menstrual_period)/7, 0);

UPDATE temp_obgyn_visit te 
set estimated_delivery_date = obs_value_datetime_from_temp(te.encounter_id,'PIH', 'ESTIMATED DATE OF CONFINEMENT');

UPDATE temp_obgyn_visit te 
set gravida = obs_value_numeric_from_temp(te.encounter_id,'PIH', 'GRAVIDITY');

UPDATE temp_obgyn_visit te 
set parity = obs_value_numeric_from_temp(te.encounter_id,'PIH', 'PARITY');

UPDATE temp_obgyn_visit te 
set abortus = obs_value_numeric_from_temp(te.encounter_id,'PIH', 'NUMBER OF ABORTIONS');

UPDATE temp_obgyn_visit te 
set living_children = obs_value_numeric_from_temp(te.encounter_id,'PIH', '11117');

UPDATE temp_obgyn_visit te 
set referral_source = obs_value_coded_list_from_temp(te.encounter_id,'PIH','7454',@locale);

drop temporary table if exists temp_obgyn_visit_dup;
create temporary table temp_obgyn_visit_dup
select * from temp_obgyn_visit;

UPDATE temp_obgyn_visit t 
set visit_count = 
	(select count(*) from temp_obgyn_visit_dup e 
	where encounter_datetime <= t.encounter_datetime
	and e.patient_id = t.patient_id);

UPDATE temp_obgyn_visit t 
set visit_date = date(t.encounter_datetime); 

UPDATE temp_obgyn_visit te 
set referral_source = obs_value_coded_list_from_temp(te.encounter_id,'PIH','7454',@locale);

set @dt = concept_from_mapping('PIH','17');
UPDATE temp_obgyn_visit te 
set anti_tetanus_vaccination = 
	(select max(o.value_datetime) from obs o 
	where o.obs_group_id in (
		select ot.obs_group_id from temp_obs ot where ot.person_id = te.patient_id
		and ot.value_coded = @dt));

UPDATE temp_obgyn_visit te 
set high_risks_for_the_pregnancy = obs_value_coded_list_from_temp(te.encounter_id,'CIEL','160079',@locale);
	
-- HIV Tests
set @hivTestId = concept_from_mapping('PIH','1040');
UPDATE temp_obgyn_visit te 
set hiv_test_obs_id_labs = latestObs(te.patient_id, @hivTestId,null);

UPDATE temp_obgyn_visit te 
inner join obs o on o.obs_id = hiv_test_obs_id_labs
set hiv_test_encounter_id_labs = o.encounter_id ;

UPDATE temp_obgyn_visit te 
inner join encounter e on e.encounter_id = hiv_test_encounter_id_labs
set hiv_test_date_labs = e.encounter_datetime ;

UPDATE temp_obgyn_visit te 
set hiv_test_result_date_labs = obs_value_datetime(hiv_test_encounter_id_labs,'PIH','10783');

UPDATE temp_obgyn_visit te 
inner join obs o on o.obs_id = hiv_test_obs_id_labs
set result_labs = concept_name(o.value_coded,@locale);

UPDATE temp_obgyn_visit te 
set hiv_test_date_form = obs_value_datetime_from_temp(te.encounter_id,'PIH','1837');

UPDATE temp_obgyn_visit te 
set result_form = obs_value_coded_list_from_temp(te.encounter_id,'PIH','2169',@locale);

UPDATE temp_obgyn_visit te 
set hiv_test_date = if(hiv_test_date_form>=hiv_test_date_labs,hiv_test_date_form,hiv_test_date_labs);

UPDATE temp_obgyn_visit te 
set result = if(hiv_test_date_form>=hiv_test_date_labs,result_form,result_labs);

UPDATE temp_obgyn_visit te 
set hiv_test_result_date = if(hiv_test_date_form>=hiv_test_date_labs,null,hiv_test_result_date_labs);

UPDATE temp_obgyn_visit te 
set not_tested_for_hiv = if(hiv_test_date is null, null, true);

SELECT name into @vitalsEncName from encounter_type where uuid = '4fb47712-34a6-40d2-8ed3-e153abbd25b7';
select form_id into @vitalsForm from form where uuid = '68728aa6-4985-11e2-8815-657001b58a90';
UPDATE temp_obgyn_visit te 
set vitals_encounter_id = latestEncForminVisit(te.patient_id,@vitalsEncName, te.visit_id, @vitalsForm, null );

UPDATE temp_obgyn_visit te 
set height_in_m = obs_value_numeric(te.vitals_encounter_id, 'PIH','5090')/100;

UPDATE temp_obgyn_visit te 
set upper_arm_circumference = obs_value_numeric(te.vitals_encounter_id, 'PIH','7956');

set @dx = concept_from_mapping('PIH','3064');
set @anemia_id = concept_from_mapping('PIH','1226');
set @malaria_id = concept_from_mapping('PIH','123');
set @severe_malaria_id = concept_from_mapping('PIH','7134');
set @cerebral_malaria_id = concept_from_mapping('PIH','11487');
set @confirmed_malaria_id = concept_from_mapping('PIH','7646');
set @malaria_pregnancy_id = concept_from_mapping('PIH','15091');
set @malaria_complicating_id = concept_from_mapping('PIH','7568');

set @malnutrition_id = concept_from_mapping('PIH','68');
set @moderate_malnutrition_id = concept_from_mapping('PIH','1312');
set @mild_malnutrition_id = concept_from_mapping('PIH','1226');
set @severe_uncomplicated_mal_id = concept_from_mapping('PIH','11340');
set @severe_malnutrition_id = concept_from_mapping('PIH','1313');

DROP TEMPORARY TABLE IF EXISTS temp_dxs;
CREATE TEMPORARY TABLE temp_dxs
(
encounter_id int(11),
dx_concept_id int(11)
);

insert into temp_dxs(encounter_id, dx_concept_id)
select o.encounter_id, o.value_coded from
temp_obs o 
inner join temp_obgyn_visit t on t.encounter_id = o.encounter_id 
and o.voided = 0
and o.concept_id = @dx
and o.value_coded in 
	(@anemia_id,
	@malaria_id,
	@severe_malaria_id,
	@cerebral_malaria_id,
	@confirmed_malaria_id,	
	@malaria_pregnancy_id,
	@malaria_complicating_id,
	@malnutrition_id,
	@moderate_malnutrition_id,
	@mild_malnutrition_id,
	@severe_uncomplicated_mal_id,
	@severe_malnutrition_id);	

UPDATE temp_obgyn_visit te 
inner join temp_dxs d on te.encounter_id = d.encounter_id and d.dx_concept_id = @anemia_id
set iron_deficiency_anemia = true;

UPDATE temp_obgyn_visit te 
inner join temp_dxs d on te.encounter_id = d.encounter_id and d.dx_concept_id IN 
	(@malaria_id,
	@severe_malaria_id,
	@cerebral_malaria_id,
	@confirmed_malaria_id,	
	@malaria_pregnancy_id,
	@malaria_complicating_id	
	)
set malaria = true;

UPDATE temp_obgyn_visit te 
inner join temp_dxs d on te.encounter_id = d.encounter_id and d.dx_concept_id IN 
	(@malnutrition_id,
	@moderate_malnutrition_id,
	@mild_malnutrition_id,
	@severe_uncomplicated_mal_id,
	@severe_malnutrition_id)
set malnutrition = true;

set @acceptsCHW = concept_from_mapping('PIH','3293');
set @yes = concept_from_mapping('PIH','1065');
set @momClub = concept_from_mapping('PIH','13261');
set @pmtctClub = concept_from_mapping('PIH','13262');
set @deliveryLocation = concept_from_mapping('PIH','13260');
set @prophylaxisPlan = concept_from_mapping('PIH','13259');

UPDATE temp_obgyn_visit te
inner join temp_obs o on o.encounter_id = te.encounter_id
	and ((o.concept_id = @acceptsCHW and o.value_coded = @yes)
	  or (o.concept_id = @momClub and o.value_coded = @yes)
      or (o.concept_id = @pmtctClub and o.value_coded = @yes)
      or (o.concept_id = @prophylaxisPlan and o.value_coded = @yes)
      or (o.concept_id = @deliveryLocation))
set birth_plan = true;      

UPDATE temp_obgyn_visit te
set accepts_accompanateur = value_coded_as_boolean(obs_id_from_temp(te.encounter_id, 'PIH','3293',0));

UPDATE temp_obgyn_visit te
set enrolled_in_mother_support_group = value_coded_as_boolean(obs_id_from_temp(te.encounter_id, 'PIH','13261',0));

select 
dossier_id,
first_name,
last_name,
mothers_first_name,
date_of_birth,
age_at_encounter,
address,
date_of_last_menstrual_period,
gestational_age,
estimated_delivery_date,
gravida,
parity,
abortus,
living_children,
referral_source,
visit_count,
visit_date,
anti_tetanus_vaccination,
high_risks_for_the_pregnancy,
hiv_test_date,
hiv_test_result_date,
result,
not_tested_for_hiv,
syphillis_details_not_tracked_in_emr,
syphiliss_treatment_start_date,
syphillis_treatment_end_date,
on_art_for_hiv_prior_to_pregnancy,
additional_hiv_details_not_in_the_emr,
height_in_m,
upper_arm_circumference,
malnutrition_malaria_details_not_in_emr,
malnutrition,
iron_deficiency_anemia,
malaria,
birth_plan,
accepts_accompanateur,
enrolled_in_mother_support_group
from temp_obgyn_visit
order by encounter_datetime desc;
