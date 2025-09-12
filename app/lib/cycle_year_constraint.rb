class CycleYearConstraint
  def matches?(request)
    current_year = Find::CycleTimetable.current_year
    permitted_years = [
      current_year - 1,
      current_year,
      current_year + 1,
    ]

    value = [request.params[:recruitment_cycle_year], request.params[:cycle_year], request.params[:year]].find(&:present?)

    value.to_i.in?(permitted_years)
  end
end
