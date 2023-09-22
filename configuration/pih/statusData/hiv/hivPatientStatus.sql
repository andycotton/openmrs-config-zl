
SELECT concept_name(concept_from_mapping('PIH', '10364'),'en')
INTO @currentTreatment
;
SELECT pp.outcome_concept_id into @outcomeConceptId from  patient_program pp 
WHERE pp.patient_id =@patientId
order by pp.date_created  desc limit 1 ;

SELECT DISTINCT pp.date_completed into @patientProgramDate
FROM patient_program pp 
WHERE pp.patient_id=@patientId
order by pp.date_created desc limit 1
;

SELECT DATE(e.encounter_datetime) into @latestDispencingDate from encounter e 
WHERE e.patient_id=@patientId
ORDER BY e.encounter_datetime LIMIT 1 ;

select e.encounter_datetime into @nextDispensingDate from encounter e 
where  e.uuid ='cc1720c9-3e4c-4fa8-a7ec-40eeaad1958c' and e.patient_id=@patientId
;

SELECT 
    CASE 
        WHEN @patientProgramDate is null or @outcomeConceptId is null then 'Program outcome'
        WHEN @patientProgramDate is not null or @outcomeConceptId is not null then concept_name(@outcomeConceptId,'en')
        WHEN DATEDIFF(NOW(), @nextDispensingDate) < 28 THEN 'active - on arvs'
        ELSE 'ltfu' 
    END into @status;

SELECT @status AS Status;