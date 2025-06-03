class RecruitmentCycleYearConstraint
  def matches?(request)
    recruitment_cycle_year_param = request.params[:recruitment_cycle_year] || request.params[:year]

    return false if recruitment_cycle_year_param.blank?

    recruitment_cycle_year_param >= RecruitmentCycle.current.year
  end
end
