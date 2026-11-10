# frozen_string_literal: true

module SupportNavigationHelper
  def support_primary_navigation_items
    [
      onboarding_navigation_item,
      providers_navigation_item,
      users_navigation_item,
      candidates_navigation_item,
      settings_navigation_item,
    ].compact
  end

private

  def onboarding_navigation_item
    support_navigation_item("layouts.support.onboarding", support_providers_onboarding_form_requests_path)
  end

  def providers_navigation_item
    support_navigation_item("layouts.support.providers", support_recruitment_cycle_providers_path(recruitment_cycle_year))
  end

  def candidates_navigation_item
    return unless FeatureFlag.active?(:candidate_accounts)

    support_navigation_item("layouts.support.candidates", support_candidates_path)
  end

  def users_navigation_item
    support_navigation_item(
      "layouts.support.users",
      support_recruitment_cycle_users_path(recruitment_cycle_year),
      active_when: [
        support_recruitment_cycle_users_path(recruitment_cycle_year),
        support_recruitment_cycle_data_exports_path(recruitment_cycle_year),
      ],
    )
  end

  def settings_navigation_item
    support_navigation_item(
      "layouts.support.settings",
      support_settings_path,
      active_when: [
        support_settings_path,
        support_feature_flags_path,
        support_recruitment_cycles_path,
        support_financial_incentives_path,
        support_banners_path,
        support_feedback_index_path,
        support_subjects_path,
      ],
    )
  end

  def support_navigation_item(label_key, href, active_when: nil)
    {
      text: t(label_key),
      href:,
      active_when: active_when || href,
    }
  end

  def recruitment_cycle_year
    params[:recruitment_cycle_year] || Find::CycleTimetable.current_year
  end
end
