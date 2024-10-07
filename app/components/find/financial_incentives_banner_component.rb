# frozen_string_literal: true

module Find
  class FinancialIncentivesBannerComponent < ViewComponent::Base
    def render?
      !FeatureFlag.active?(:bursaries_and_scholarships_announced)
    end
  end
end
