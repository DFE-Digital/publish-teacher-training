module Sites
  class CopyToCourseService
    def execute(new_site:, new_course:)
      new_vac_status = SiteStatus.default_vac_status_given(
        study_mode: new_course.study_mode,
      )

      new_course.site_statuses.create(
        site: new_site,
        vac_status: new_vac_status,
        status: :new_status,
      )
    end
  end
end
