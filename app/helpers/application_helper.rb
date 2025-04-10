# frozen_string_literal: true

module ApplicationHelper
  include Pagy::Frontend
  include DfE::Autocomplete::ApplicationHelper

  def pagy_govuk_nav(pagy)
    render "pagy/paginator", pagy:
  end

  def header_items(current_user)
    return unless current_user

    [{ name: t("header.items.sign_out"), url: sign_out_path }]
  end

  # rubocop:disable Rails/HelperInstanceVariable
  # TODO: refactor enrichment_error_link method to not use an instance variable
  def enrichment_error_link(model, field, error)
    href = case model
           when :course
             enrichment_error_url(
               provider_code: @provider.provider_code,
               course: @course,
               field: field.to_s,
               message: error,
             )
           when :provider
             provider_enrichment_error_url(
               provider: @provider,
               field: field.to_s,
             )
           end

    govuk_inset_text(classes: "app-inset-text--narrow-border app-inset-text--error") do
      govuk_link_to(error, href)
    end
  end

  # TODO: refactor enrichment_summary method to not use an instance variable
  def enrichment_summary(summary_list, model, key, value, fields, action_path: nil, action_visually_hidden_text: nil, render_errors: true)
    action = render_action(action_path, action_visually_hidden_text || key.downcase)
    if fields.any? { |field| @errors&.key? field.to_sym }
      errors = fields.map { |field|
        @errors[field.to_sym]&.map { |error| enrichment_error_link(model, field, error) }
      }.flatten

      value = raw(*errors) if render_errors.present?
      action = nil
    end

    value = raw('<span class="app-!-colour-muted">Empty</span>') if value.blank?

    summary_list.with_row(html_attributes: { data: { qa: "enrichment__#{fields.first}" } }) do |row|
      row.with_key { key.html_safe }
      row.with_value(classes: %w[govuk-summary-list__value]) { value }
      if action
        row.with_action(**action)
      else
        row.with_action
      end
    end
  end
  # rubocop:enable Rails/HelperInstanceVariable

  def dont_display_phase_banner_border?(user)
    user && !user.admin? && user.providers.where(recruitment_cycle: RecruitmentCycle.current).one? && !FeatureService.enabled?("rollover.can_edit_current_and_next_cycles")
  end

private

  def render_action(action_path, action_visually_hidden_text)
    return if action_path.blank?

    {
      href: action_path,
      visually_hidden_text: action_visually_hidden_text,
    }
  end
end
