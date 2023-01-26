# frozen_string_literal: true

module Find
  module LocationHelper
    def provider_error?
      return false if flash[:error].nil?

      flash[:error].include?(t("find.location_filter.fields.provider")) ||
        flash[:error].include?(t("find.location_filter.errors.blank_provider")) ||
        flash[:error].include?(t("find.location_filter.errors.missing_provider"))
    end

    def location_error?
      return false if flash[:error].nil?

      flash[:error].include?(I18n.t("find.location_filter.errors.missing_location"))
    end

    def no_option_selected?
      return false if flash[:error].nil?

      flash[:error].include?(I18n.t("find.location_filter.errors.no_option"))
    end
  end
end
