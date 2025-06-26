# frozen_string_literal: true

module Govuk
  class OneLoginHeaderComponent < GovukComponent::HeaderComponent
    attr_reader :current_user

    # data-module="one-login-header" is used to initialize the js on mobile
    def initialize(current_user:, html_attributes: { data: { module: "one-login-header" } })
      super(html_attributes:)

      @current_user = current_user
    end

    def sign_out_link
      button_to("Sign out", find_sign_out_path, class: %w[
        one-login-header__nav__link--one-login
        one-login-header__button-link
        one-login-header__nav__link
      ], method: :delete)
    end

    def sign_in_link
      button_to("Sign in", path, class: %w[
        one-login-header__nav__link--one-login
        one-login-header__button-link
        one-login-header__nav__link
      ], method: :post)
    end

    def path
      if Settings.one_login.enabled
        "/auth/one-login"
      else
        "/auth/find-developer"
      end
    end
  end
end
