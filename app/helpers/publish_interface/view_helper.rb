module PublishInterface
  module ViewHelper
    def govuk_back_link_to(url = :back, body = "Back")
      render GovukComponent::BackLinkComponent.new(
        text: body,
        href: url,
        classes: "govuk-!-display-none-print",
        html_attributes: {
          data: {
            qa: "page-back",
          },
        },
      )
    end

    def bat_contact_mail_to(name = nil, **kwargs)
      govuk_mail_to bat_contact_email_address, name || bat_contact_email_address_with_wrap, **kwargs
    end

    def bat_contact_email_address
      Settings.support_email
    end

    def bat_contact_email_address_with_wrap
      # https://developer.mozilla.org/en-US/docs/Web/HTML/Element/wbr
      # The <wbr> element will not be copied when copying and pasting the email address
      bat_contact_email_address.gsub("@", "<wbr>@").html_safe
    end

    def title_with_error_prefix(title, error)
      "#{t('page_titles.error_prefix') if error}#{title}"
    end

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

  private

    def render_action(action_path, action_visually_hidden_text)
      return if action_path.blank?

      {
        href: action_path,
        visually_hidden_text: action_visually_hidden_text,
      }
    end
  end
end
