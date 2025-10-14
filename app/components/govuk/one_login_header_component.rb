# frozen_string_literal: true

module Govuk
  class OneLoginHeaderComponent < GovukComponent::HeaderComponent
    attr_reader :current_user

    # data-module="one-login-header" is used to initialize the js on mobile
    def initialize(current_user:, html_attributes: { data: { module: "one-login-header" } })
      super(html_attributes:)

      @current_user = current_user
    end

    def account_link
      Settings.one_login.profile_url
    end

    def sign_out_link
      button_to(find_sign_out_path,
                class: %w[
                  one-login-header__button-link
                  rebranded-one-login-header__nav__link
                ],
                form_class: %w[
                  one-login-header__button-form
                ],
                method: :delete) do
                  tag.span("Sign out", class: %w[rebranded-one-login-header__nav__link-content])
                end
    end

    def sign_in_link
      button_to(path,
                class: %w[
                  one-login-header__button-link
                  rebranded-one-login-header__nav__link
                ],
                form_class: %w[
                  one-login-header__button-form
                ], method: :post) do
                  tag.span("Sign in", class: %w[rebranded-one-login-header__nav__link-content])
                end
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
