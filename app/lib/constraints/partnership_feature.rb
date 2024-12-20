# frozen_string_literal: true

module Constraints
  class PartnershipFeature
    def initialize(setting)
      @setting = setting
    end

    def matches?(_request)
      if @setting == :on
        Settings.features.provider_partnerships
      else
        !Settings.features.provider_partnerships
      end
    end
  end
end
