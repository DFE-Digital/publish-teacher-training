SELECT course.id as id, course.program_type, course.qualification, course.study_mode, course.is_send, course.degree_grade,
provider.provider_name, provider.can_sponsor_student_visa, provider.can_sponsor_skilled_worker_visa, provider.recruitment_cycle_id,
subject.subject_code, 
course_site.vac_status, course_site.publish, course_site.status, 
site.latitude, site.longitude
FROM course
INNER JOIN provider on provider.id = course.provider_id 
INNER JOIN course_subject on course_subject.course_id = course.id
INNER JOIN subject on subject.id = course_subject.subject_id
INNER JOIN course_site on course_site.course_id = course.id
INNER JOIN site on site.id = course_site.site_id
