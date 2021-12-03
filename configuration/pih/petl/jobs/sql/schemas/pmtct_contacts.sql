CREATE TABLE pmtct_contacts
(
patient_id int,
age int, 
hiv_enrollment_date datetime,
pmtct_initiation_date datetime,
art_start_date datetime,
reference_date datetime,
contact_index int,
contact_type varchar(255),
contact_gender varchar(255),
contact_bond varchar(255),
contact_dob datetime,
contact_has_posttest_counseling varchar(255),
contact_hiv_status_cat varchar(255),
contact_hiv_test_date datetime,
contact_hiv_test_result varchar(255),
contact_hiv_status varchar(255),
contact_is_active_on_art varchar(255),
contact_posttest_counseling_date datetime
);
