# frozen_string_literal: true

class Support::AddProviderWizard
  # The rows of the check answers page. Labels come from
  # activemodel.attributes for each step class.
  class CheckAnswersPresenter
    include DfE::Wizard::CheckAnswersPresenter

    def provider_rows
      rows_for(:provider_details, provider_attributes)
    end

    def contact_rows
      rows_for(:contact_details, %i[email telephone website full_address])
    end

    def format_value(attribute, value)
      case attribute
      when :accredited then ActiveModel::Type::Boolean.new.cast(value) ? "Yes" : "No"
      when :provider_type then value.presence && I18n.t("support.providers.provider_type.#{value}")
      else value
      end
    end

    # "Provider name" becomes "provider name". An acronym such as "UK"
    # stays as it is.
    def visually_hidden_text(row)
      row.label.sub(/\A[A-Z](?=[a-z])/, &:downcase)
    end

  private

    def provider_attributes
      provider = find_reviewable_step(:provider_details)

      [
        :provider_name,
        :provider_code,
        :ukprn,
        :accredited,
        (:accredited_provider_number if provider&.accredited?),
        :provider_type,
        (:urn if provider&.lead_school?),
      ].compact
    end
  end
end
