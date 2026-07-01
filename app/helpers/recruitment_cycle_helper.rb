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

  def hint_text_for_mid_cycle
    "#{I18n.t('find.cycles.today_is_mid_cycle.description')} (#{Find::CycleTimetable.find_opens.to_fs(:govuk_date_and_time)} to #{Find::CycleTimetable.apply_deadline.to_fs(:govuk_date)})"
  end

  def hint_text_for_after_apply_deadline_passed
    "#{I18n.t('find.cycles.today_is_after_apply_deadline_passed.description')} (#{Find::CycleTimetable.apply_deadline.to_fs(:govuk_date)} to #{Find::CycleTimetable.find_closes.to_fs(:govuk_date)})"
  end

  def hint_text_for_now_is_before_find_opens
    "#{I18n.t('find.cycles.now_is_before_find_opens.description')} (#{Find::CycleTimetable.find_closes(Find::CycleTimetable.current_year).to_fs(:govuk_date_and_time)} to #{Find::CycleTimetable.find_opens(Find::CycleTimetable.next_year).to_fs(:govuk_date_and_time)})"
  end

  def hint_text_for_today_is_after_find_opens
    "#{I18n.t('find.cycles.today_is_after_find_opens.description')} (#{Find::CycleTimetable.find_reopens.to_fs(:govuk_date)})"
  end

  def hint_text_for_today_is_between_find_opening_and_apply_opening
    "#{I18n.t('find.cycles.today_is_between_find_opening_and_apply_opening.description')} (#{Find::CycleTimetable.find_reopens.to_fs(:govuk_date)})"
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
