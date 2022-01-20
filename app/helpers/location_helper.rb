module LocationHelper
  def urn_required?(recruitment_cycle_year)
    recruitment_cycle_year >= Site::URN_2022_REQUIREMENTS_REQUIRED_FROM
  end
end
