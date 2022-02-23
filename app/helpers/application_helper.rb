module ApplicationHelper
  # include Pagy::Frontend

  def header_items(current_user)
    return unless current_user

    items = [{ name: t("header.items.sign_out"), url: sign_out_path }]
    items
  end

  # def pagy_govuk_nav(pagy)
  #   render "pagy/paginator", pagy: pagy
  # end

  # def enrichment_error_link(model, field, error)
  #   href = case model
  #          when :course
  #            enrichment_error_url(
  #              provider_code: @provider.provider_code,
  #              course: @course,
  #              field: field.to_s,
  #              message: error,
  #            )
  #          when :provider
  #            provider_enrichment_error_url(
  #              provider: @provider,
  #              field: field.to_s,
  #            )
  #          end

  #   govuk_inset_text(classes: "app-inset-text--narrow-border app-inset-text--error") do
  #     govuk_link_to(error, href)
  #   end
  # end

  # TODO: refactor enrichment_summary method to not use an instance variable
  # rubocop:disable Rails/HelperInstanceVariable
  def enrichment_summary(summary_list, model, key, value, fields, truncate_value: true, action_path: nil, action_visually_hidden_text: nil)
    action = render_action(action_path, action_visually_hidden_text)

    if fields.select { |field| @errors&.key? field.to_sym }.any?
      errors = fields.map { |field|
        @errors[field.to_sym]&.map { |error| enrichment_error_link(model, field, error) }
      }.flatten

      value = raw(*errors)
      action = nil
    elsif truncate_value
      classes = "app-summary-list__value--truncate"
    end

    if value.blank?
      value = raw("<span class=\"app-!-colour-muted\">Empty</span>")
    end

    summary_list.row(html_attributes: { data: { qa: "enrichment__#{fields.first}" } }) do |row|
      row.key { key.html_safe }
      row.value(classes: classes) { value }
      if action
        row.action(action)
      else
        row.action
      end
    end
  end
# rubocop:enable Rails/HelperInstanceVariable

private

  def render_action(action_path, action_visually_hidden_text)
    return if action_path.blank?

    {
      href: action_path,
      visually_hidden_text: action_visually_hidden_text,
    }
  end
end
