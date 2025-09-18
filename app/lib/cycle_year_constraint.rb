class CycleYearConstraint
  def matches?(request)
    permitted_years = [
      Find::CycleTimetable.previous_year,
      Find::CycleTimetable.current_year,
      Find::CycleTimetable.next_year,
    ]

    possible_year_params = [
      request.params[:recruitment_cycle_year],
      request.params[:cycle_year],
      request.params[:year],
    ].find(&:present?)

    possible_year_params.to_i.in?(permitted_years)
  end
end
