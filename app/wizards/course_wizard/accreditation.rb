# frozen_string_literal: true

class CourseWizard
  class Accreditation
    def initialize(provider:, selected_provider_code: nil)
      @provider = provider
      @selected_provider_code = selected_provider_code
    end

    def selection_required?
      requires_partner? && partners.many?
    end

    def accrediting_provider
      return unless requires_partner?
      return partners.first if partners.one?

      selected_partner
    end

    def partners
      @partners ||= provider.accredited_partners.sort_by(&:provider_name)
    end

  private

    attr_reader :provider, :selected_provider_code

    def requires_partner?
      !provider.accredited?
    end

    def selected_partner
      return if selected_provider_code.blank?

      partners.find { |partner| partner.provider_code == selected_provider_code }
    end
  end
end
