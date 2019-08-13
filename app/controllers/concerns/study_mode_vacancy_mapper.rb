module StudyModeVacancyMapper
  extend ActiveSupport::Concern

  def update_vac_status(study_mode, site_status)
    case study_mode
    when "full_time"
      site_status.update(vac_status: :full_time_vacancies)
    when "part_time"
      site_status.update(vac_status: :part_time_vacancies)
    when "full_time_or_part_time"
      site_status.update(vac_status: :both_full_time_and_part_time_vacancies)
    else
      raise "Unexpected study mode #{study_mode}"
    end
  end
end
