# frozen_string_literal: true

module Find
  class CookiePreferencesController < ApplicationController
    def show
      @cookie_preferences_form = CookiePreferencesForm.new(cookies)
    end

    def update
      @cookie_preferences_form = CookiePreferencesForm.new(cookies, cookie_preferences_params)

      if @cookie_preferences_form.save
        redirect_back(fallback_location: root_path, flash: { success: I18n.t('cookies.preferences.success') })
      else
        render(:show)
      end
    end

    private

    def cookie_preferences_params
      params.require(:find_cookie_preferences_form).permit(:analytics_consent)
    end
  end
end
