# Gender
select gender into @gender from person where person_id = @patientId;

# Estimated delivery date
select o.value_datetime into @edd 
from obs o
where o.obs_id = latest_obs(@patientId, 'CIEL', '5596')
and o.voided = 0;

# Date of last period
select o.value_datetime into @dolp 
from obs o
where o.obs_id = latest_obs(@patientId, 'CIEL', '1427')
and o.voided = 0;

# Date of delivery
select o.value_datetime into @dod 
from obs o
where o.obs_id = latest_obs(@patientId, 'CIEL', '5599')
and o.voided = 0;

select
    @gender as gender,
    if (@dolp > ifnull(@dod, 0), true, false) as pregnant,
    if (@dolp > ifnull(@dod, 0), date(@edd), null) as dueDate;