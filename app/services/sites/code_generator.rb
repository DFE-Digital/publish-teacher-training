module Sites
  class CodeGenerator
    include ServicePattern

    def initialize(provider:)
      @provider = provider
    end

    def call
      ucas_style_code.presence || highest_site_code.next
    end

  private

    attr_reader :provider

    def highest_site_code
      return "Z" if existing_sequential_codes.blank?

      existing_sequential_codes.max
    end

    def existing_sequential_codes
      (existing_site_codes - Site::POSSIBLE_CODES).compact
    end

    def existing_site_codes
      @existing_site_codes ||= provider.sites.pluck(:code)
    end

    def unassigned_ucas_style_site_codes
      Site::POSSIBLE_CODES - existing_site_codes
    end

    def ucas_style_code
      @ucas_style_code ||= begin
        available_desirable_codes = unassigned_ucas_style_site_codes & Site::DESIRABLE_CODES
        available_undesirable_codes = unassigned_ucas_style_site_codes & Site::EASILY_CONFUSED_CODES

        available_desirable_codes.sample || available_undesirable_codes.sample
      end
    end
  end
end
