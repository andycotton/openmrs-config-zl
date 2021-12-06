-- set @locale = 'en';  -- uncomment for testing

select program_workflow_state_id into @patientPregnant from program_workflow_state where concept_id = concept_from_mapping('PIH','1755');

drop temporary table if exists temp_contacts;

create temporary table temp_contacts
(
patient_id int,
concept_obs_group_id int,
age int,
hiv_enrollment_date datetime,
pmtct_initiation_date datetime,
art_start_date datetime,
reference_date datetime,
contact_type varchar(255),
contact_gender varchar(50), -- need to add to form
contact_index int,
contact_dob datetime,  -- need to add to form
contact_has_posttest_counseling varchar(255),   -- need to add to form
contact_hiv_status_cat varchar(255),  -- need to add to form
contact_hiv_test_date datetime,  -- need to add to form
contact_hiv_test_result varchar(255),  -- need to add to form
contact_hiv_status varchar(255), 
contact_is_active_on_art varchar(255),  -- need to add to form
contact_posttest_counseling_date datetime  -- need to add to form
);

-- loads temp table with all contacts entered
-- note that the contact_index numbers the contacts within patients 
insert into temp_contacts (contact_index,patient_id,concept_obs_group_id,reference_date)
select @r:= IF(@u = person_id, @r + 1,1),@u:=person_id, obs_id, obs_datetime 
from obs o 
where o.voided = 0
and concept_id = concept_from_mapping('PIH','13182')
order by person_id, o.obs_datetime asc, obs_id asc;

-- current age
update temp_contacts
set age = current_age_in_years(patient_id);

-- hiv enrollment date from the latest enrollment date of the patient's hiv program
update temp_contacts
set hiv_enrollment_date = latestProgramEnrollmentDate(patient_id,'b1cb1fc1-5190-4f7a-af08-48870975dafc');

-- this pulls the pmtct initiation date, which is the start date of the patient state of "pregnant" for the patient's latest enrollment
update temp_contacts t 
inner join 
	(select pp.patient_id, pp.date_enrolled, max(start_date) as pregnant_start_date from patient_state ps
	inner join patient_program pp on ps.patient_program_id = pp.patient_program_id 
	and state = @patientPregnant
	group by patient_id,pp.date_enrolled) s on s.patient_id = t.patient_id and s.date_enrolled = t.hiv_enrollment_date
set	pmtct_initiation_date = s.pregnant_start_date;

-- art start date 
update temp_contacts t
set art_start_date = orderReasonStartDate(t.patient_id,'PIH','11197');

-- contact type
update temp_contacts t 
set contact_type = obs_from_group_id_value_coded_list(t.concept_obs_group_id, 'PIH','13265',@locale);

-- contact hiv status
update temp_contacts t 
set contact_hiv_status = obs_from_group_id_value_coded_list(t.concept_obs_group_id, 'PIH','2169',@locale);

select 
patient_id,
age,
hiv_enrollment_date,
pmtct_initiation_date,
art_start_date,
reference_date,
contact_index,
contact_type,
contact_gender,
contact_dob,
contact_has_posttest_counseling,
contact_hiv_status_cat,
contact_hiv_test_date,
contact_hiv_test_result,
contact_hiv_status,
contact_is_active_on_art,
contact_posttest_counseling_date
from temp_contacts
;
