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

  def switcher_option_label(option)
    year = Find::CycleTimetable.year_for_option(option)
    from, to = Find::CycleTimetable.option_range(option, year)

    safe_join([
      t("find.cycles.#{option}.name"),
      tag.span(" - #{switcher_date_range(from, to)}", class: "govuk-hint govuk-!-margin-bottom-0"),
    ])
  end

  def switcher_cycle_group_heading(option)
    year = Find::CycleTimetable.year_for_option(option)
    key = option == :apply_open ? "find.cycles.groups.current" : "find.cycles.groups.next"

    t(key, from: year - 1, to: year)
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

private

  def switcher_date_range(from, to)
    start_date = from.to_date.year == to.to_date.year ? from.to_fs(:day_and_month) : from.to_fs(:govuk_date)

    "#{start_date} to #{to.to_fs(:govuk_date)}"
  end
end
