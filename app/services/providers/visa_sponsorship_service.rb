module Providers
  class VisaSponsorshipService
    VISA_SPONSORSHIP_INTRODUCED_IN = 2022

    def initialize(provider)
      @provider = provider
    end

    def visa_sponsorship_enabled?
      @provider.recruitment_cycle_year.to_i >= VISA_SPONSORSHIP_INTRODUCED_IN
    end
  end
end
