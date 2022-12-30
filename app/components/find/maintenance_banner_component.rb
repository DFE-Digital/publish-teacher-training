module Find
  class MaintenanceBannerComponent < ViewComponent::Base
    include ::ViewHelper
    def render?
      FeatureFlag.active?(:maintenance_banner) && !FeatureFlag.active?(:maintenance_mode)
    end
  end
end
