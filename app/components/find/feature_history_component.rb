module Find
  class FeatureHistoryComponent < ViewComponent::Base
    include ViewHelper

    def initialize(feature_name)
      super
      @feature_name = feature_name
    end

    def history
      if last_updated
        formatted_date = DateTime.parse(last_updated).to_fs(:govuk_date_and_time)
        "Changed to #{status} at #{formatted_date}"
      else
        "This flag has not been updated"
      end
    end

  private

    def last_updated
      FeatureFlag.last_updated(@feature_name)
    end

    def status
      FeatureFlag.active?(@feature_name) ? "active" : "inactive"
    end
  end
end
