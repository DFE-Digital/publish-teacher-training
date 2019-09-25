module Sites
  class CopyToCourseService
    def execute(new_site:, new_course:)
      new_vac_status = SiteStatus.default_vac_status_given(
        study_mode: new_course.study_mode,
      )
      new_start_date = new_course.recruitment_cycle.application_start_date

      new_course.site_statuses.create(
        site: new_site,
        vac_status: new_vac_status,
        applications_accepted_from: new_start_date,
        status: :new_status,
      )
    end
  end
end
