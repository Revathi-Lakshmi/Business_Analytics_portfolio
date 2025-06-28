create database HealthCare_Analytics;
use HealthCare_Analytics;

#TASK 1 fetch details of all completed appointments, including the patient’s name, doctor’s name, and specialization(Inner Join)
select 
p.name as patient_name, 
d.name as doctor_name, 
d.specialization, 
a.appointment_date, 
a.status
from appointments a
join patients p on a.patient_id = p.patient_id
join doctors d on a.doctor_id = d.doctor_id
where a.status = 'completed'
order by a.appointment_date desc;
    
#TASK 2 Left Join with Null Handling(Retrieve all patients who have never had an appointment)
    
select 
p.name as patient_name, 
p.contact_number as contact_details, 
p.address as address
from patients p
left join appointments a on p.patient_id = a.patient_id
where a.patient_id is null;

select p.*
from patients p
left join appointments a on p.patient_id = a.patient_id
where a.patient_id is null;

#TASK 3 Right Join and Aggregate Functions(Find the total number of diagnoses for each doctor, including doctors who haven’t diagnosed any patients)

select 
d.name as doctor_name, 
d.specialization, 
count(di.diagnosis_id) as total_diagnoses
from doctors d
right join diagnoses di on d.doctor_id = di.doctor_id
group by d.doctor_id, d.name, d.specialization
order by total_diagnoses desc;

#TASK 4 Full Join for Overlapping Data(Write a query to identify mismatches between the appointments and diagnoses tables)

select 
a.appointment_id, 
a.patient_id as appointment_patient_id, 
d.patient_id as diagnosis_patient_id, 
d.diagnosis_id
from appointments a
left join diagnoses d 
on a.patient_id = d.patient_id
where d.diagnosis_id is null  #Appointments without a diagnosis

union

select 
null as appointment_id, 
null as appointment_patient_id, 
d.patient_id AS diagnosis_patient_id, 
d.diagnosis_id
from diagnoses d
left join appointments a 
on d.patient_id = a.patient_id
where a.patient_id is null;  #Diagnoses without an appointment
 
#TASK 5 Window Functions (Ranking and Aggregation)
#For each doctor, rank their patients based on the number of appointments in descending order.

select 
d.name as doctor_name, 
d.specialization, 
p.name as patient_name, 
count(a.appointment_id) as total_appointments, 
dense_rank() over (partition by d.doctor_id order by count(a.appointment_id) desc) as rank_position
from appointments a
join patients p on a.patient_id = p.patient_id
join doctors d on a.doctor_id = d.doctor_id
group by d.doctor_id, d.name, d.specialization, p.patient_id, p.name
order by d.doctor_id, rank_position;
    
#TASK 6 Conditional Expressions
#categorize patients by age group (18-30, 31-50, 51+). Count the number of patients in each age group.

select 
    case 
		when age < 18 then '<18'
        when age between 18 and 30 then '18-30'
        when age between 31 and 40 then '31-40'
        when age between 41 and 50 then '41-50'
        when age between 51 and 60 then '51-60'
        when age >= 61 then '61+'
        else 'unknown'  			#handles cases where age is null
    end as age_group,
    count(*) as total_patients
from patients
group by age_group
order by age_group;
    
#TASK 7 Numeric and String Functions
#Retrieve a list of patients whose contact numbers end with "1234" and display their names in uppercase.

select 
upper(name) as patient_name, 
contact_number as contact_details
from patients
where contact_number like '%1234';           #Filters based on pattern matching and removes character/numebers before "%"

#TASK 8 Subqueries for Filtering
#Find patients who have only been prescribed "Insulin" in any of their diagnoses.

select
p.patient_id, 
p.name as patient_name
from patients p
join diagnoses d on p.patient_id = d.patient_id
join medications m on d.diagnosis_id = m.diagnosis_id
where m.medication_name = 'insulin'							#until this it includes patients who are prescribed medicines along with insulin but not only "insulin"
and 														#For retriving patients who are prescribed only INSULIN and not other medication
    p.patient_id not in (
        select distinct d2.patient_id
        from diagnoses d2
        join medications m on d2.diagnosis_id = m.diagnosis_id
        where m.medication_name <> 'insulin'
    )
order by p.name;
    
    #TASK 9 Date and Time Functions
    #Calculate the average duration (in days) for which medications are prescribed for each diagnosis.

select 
d.diagnosis_id, 
d.patient_id, 
avg(datediff(m.end_date, m.start_date)) as avg_duration_days
from diagnoses d
join medications m on d.diagnosis_id = m.diagnosis_id
group by 
d.diagnosis_id, d.patient_id
order by 
avg_duration_days desc;
    
#TASK 10 Complex Joins and Aggregation
#identify the doctor who has attended the most unique patients. Include the doctor’s name, specialization, and the count of unique patients.

select 
d.doctor_id, 
d.name as doctor_name, 
d.specialization, 
count(distinct a.patient_id) as unique_patient_count
from doctors d
join appointments a on d.doctor_id = a.doctor_id
group by d.doctor_id, d.name, d.specialization
order by unique_patient_count desc
limit 5;


#BUSINESS QUESTIONS
#1.1 Demographic analysis

select 
    case 
        when age between 0 and 17 then '0-17'
        when age between 18 and 30 then '18-30'
        when age between 31 and 40 then '31-40'
        when age between 41 and 50 then '41-50'
        when age between 51 and 60 then '51-60'
        when age >= 61 then '61+'
        else 'unknown'
    end as age_group,
    gender,
    count(*) as patient_count
from patients
group by age_group, gender
order by age_group;
    
#2. Appointment Trend(cancellations, and completions)

select 
status, 
count(*) as total_appointments
from appointments
group by status;

#3.appointment trends analysis(monthly appointment trend)

select 
date_format(appointment_date, '%y-%m') as month, 
count(*) as total_appointments
from appointments
group by month
order by month desc;									#track appointment volumes over time to detect seasonal trends.
    
#4 Medication analysis: Identifying the most common medications prescribed to patients based on diagnoses

select m.medication_name, 
count(*) as medication_count
from medications m
group by m.medication_name
order by medication_count desc
limit 5;								#identifies common medications for stock & supply management.








