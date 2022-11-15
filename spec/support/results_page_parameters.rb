def results_page_parameters(parameters = {})
  {
    'filter[has_vacancies]' => 'true',
    'include' => 'site_statuses.site,subjects,provider',
    'fields' =>
      {
        'courses' => 'name,course_code,provider_code,study_mode,qualification,funding_type,provider_type,level,provider,site_statuses,subjects,recruitment_cycle_year,degree_grade,can_sponsor_student_visa,can_sponsor_skilled_worker_visa',
        'providers' => 'provider_name,address1,address2,address3,address4,postcode',
        'site_statuses' => 'status,has_vacancies?,site',
        'subjects' => 'subject_name,subject_code,bursary_amount,scholarship',
      },
    'page[page]' => 1,
    'page[per_page]' => 30,
    'sort' => 'provider.provider_name,name',
  }.merge(parameters)
end
