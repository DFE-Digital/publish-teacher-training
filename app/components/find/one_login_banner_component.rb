# frozen string_literal: true

module Find
  class OneLoginBannerComponent < ApplicationComponent
    attr_reader :text, :title

    DEFAULT_CLASS = "govuk-notification-banner".freeze

    def default_classes
      DEFAULT_CLASS
    end

    def one_login_path
      if Settings.one_login.enabled
        "/auth/one-login"
      else
        "/auth/find-developer"
      end
    end
  end
end
