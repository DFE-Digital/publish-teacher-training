# frozen_string_literal: true

module RecruitmentCycleHelper
  def current_recruitment_cycle_period_text
    "#{Find::CycleTimetable.previous_year} to #{Find::CycleTimetable.current_year}"
  end

  def next_recruitment_cycle_period_text
    "#{Find::CycleTimetable.current_year} to #{Find::CycleTimetable.next_year}"
  end

  def next_academic_cycle_period_text
    "#{Find::CycleTimetable.next_year} to #{Find::CycleTimetable.next_year + 1}"
  end

  def previous_recruitment_cycle_period_text
    "#{Find::CycleTimetable.previous_year - 1} to #{Find::CycleTimetable.previous_year}"
  end

  def hint_for_option(option, year = Find::CycleTimetable.year_for_option(option))
    from, to = Find::CycleTimetable.option_range(option, year)
    description = I18n.t("find.cycles.#{option}.description")

    safe_join(
      [
        tag.strong("#{year} cycle."),
        " #{description} (#{from.to_fs(:govuk_date_and_time)} to #{to.to_fs(:govuk_date)})",
      ],
    )
  end

  def current_recruitment_cycle?(provider)
    provider.recruitment_cycle_year.to_i == Find::CycleTimetable.current_year
  end

  def rollover_active?
    RolloverPeriod.active?(current_user:)
  end

  def current_cycle_provider(provider)
    RecruitmentCycle.current.providers.find_by(provider_code: provider.provider_code)
  end

  def next_cycle_provider(provider)
    RecruitmentCycle.next.providers.find_by(provider_code: provider.provider_code)
  end
end
