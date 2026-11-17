# frozen_string_literal: true

module Find
  class CookiePreferencesController < ApplicationController
    def show
      @cookie_preferences_form = CookiePreferencesForm.new(cookies)
    end

    def update
      return redirect_back(fallback_location: find_root_path) if params[:hide]

      @cookie_preferences_form = CookiePreferencesForm.new(cookies, analytics_consent: analytics_consent_param)

      if @cookie_preferences_form.save
        redirect_back(fallback_location: find_root_path, flash: { analytics_consent: @cookie_preferences_form.analytics_consent })
      else
        render :show, status: :unprocessable_content
      end
    end

  private

    def analytics_consent_param
      params.expect(find_cookie_preferences_form: [:analytics_consent])[:analytics_consent]
    end
  end
end
