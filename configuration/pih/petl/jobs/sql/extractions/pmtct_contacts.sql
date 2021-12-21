-- set @locale = 'en';  -- uncomment for testing

select program_id into @hivProgram from program where uuid = 'b1cb1fc1-5190-4f7a-af08-48870975dafc';

select program_workflow_state_id into @patientPregnantState 
from program_workflow_state where uuid = '5da5fa62-ef9f-4f15-9b58-d23136c2907b';

drop temporary table if exists temp_contacts;

create temporary table temp_contacts
(
patient_id int,
zlemrid varchar(255),
concept_obs_group_id int,
age int,
latest_patient_program_id int, 
hiv_enrollment_date datetime,
pmtct_initiation_date datetime,
art_start_date datetime,
reference_date datetime,
contact_index int,
contact_type varchar(255),
contact_gender varchar(50),
contact_death_status varchar(255),
contact_age int,  
contact_posttest_services varchar(255),   
contact_hiv_status_cat varchar(255) 
);

-- loads temp table with all contacts entered
-- note that the contact_index numbers the contacts within patients 
insert into temp_contacts (contact_index,patient_id,concept_obs_group_id,reference_date)
select @r:= IF(@u = person_id, @r + 1,1),@u:=person_id, obs_id, obs_datetime 
from obs o 
where o.voided = 0
and concept_id = concept_from_mapping('PIH','13182')
order by person_id, o.obs_datetime asc, obs_id asc;

-- zl emr id
update temp_contacts
set zlemrid = zlemr(patient_id);

-- current age
update temp_contacts
set age = current_age_in_years(patient_id);

-- populates latest patient program for HIV for each patient
update temp_contacts t
inner join patient_program pp on pp.patient_program_id =
	(select patient_program_id from patient_program pp2 
	where pp2.patient_id = t.patient_id
	and pp2.program_id = @hivProgram
	order by date_enrolled desc limit 1)
set latest_patient_program_id = pp.patient_program_id,
	hiv_enrollment_date = pp.date_enrolled ;

-- set pmtct initiation date to most recent start of patient pregant state for the patient program id
update temp_contacts t 
inner join patient_state ps on ps.patient_state_id =
	(select patient_state_id from patient_state ps2
	where ps2.patient_program_id = t.latest_patient_program_id
	and ps2.state =  @patientPregnantState
	order by ps2.start_date desc limit 1)
set pmtct_initiation_date = ps.start_date ;

-- art start date as the start date of orders with order reason of hiv
update temp_contacts t
set art_start_date = orderReasonStartDate(t.patient_id,'PIH','11197');

-- contact type
update temp_contacts t 
set contact_type = obs_from_group_id_value_coded_list(t.concept_obs_group_id, 'PIH','13265',@locale);

-- contact gender
update temp_contacts t 
set contact_gender = obs_from_group_id_value_coded_list(t.concept_obs_group_id, 'PIH','2845',@locale);

-- contact hiv status
update temp_contacts t 
set contact_hiv_status_cat = obs_from_group_id_value_coded_list(t.concept_obs_group_id, 'PIH','13955',@locale);

update temp_contacts t 
set contact_death_status= obs_from_group_id_value_coded_list(t.concept_obs_group_id, 'PIH','11333',@locale);

update temp_contacts t 
set contact_age= obs_from_group_id_value_numeric(t.concept_obs_group_id, 'PIH','3467');

update temp_contacts t 
set contact_posttest_services= obs_from_group_id_value_coded_list(t.concept_obs_group_id, 'PIH','13955',@locale);



/*
 contact_index int,
contact_type varchar(255),
contact_gender varchar(50),
contact_dead boolean,
contact_age datetime,  
contact_posttest_services varchar(255),   
 varchar(255), 
 */

select 
patient_id,
zlemrid,
age,
hiv_enrollment_date,
pmtct_initiation_date,
art_start_date,
reference_date,
contact_index,
contact_type,
contact_gender,
contact_death_status,
contact_age,  
contact_posttest_services,   
contact_hiv_status_cat 
from temp_contacts
;
