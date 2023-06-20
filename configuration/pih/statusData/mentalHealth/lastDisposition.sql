select concept_from_mapping('PIH', '8620')
into @dispositionCategory;



# Get the latest value_coded with dispositionCategory 
SELECT o.value_coded  into @valueCoded
FROM obs o
where o.person_id = @patientId
and o.concept_id = @dispositionCategory
and o.voided = 0
order by o.obs_datetime desc
limit 1;

select
    @valueCoded as disposition;