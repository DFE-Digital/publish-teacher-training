# frozen_string_literal: true

module FeatureHelpers
  module Authentication
    attr_reader :current_user

    def given_i_am_authenticated(user: nil)
      @current_user = user || create(:user)
      user_exists_in_dfe_sign_in(user: @current_user)

      visit_sign_in_page
    end

    def visit_sign_in_page
      sign_in_page = PageObjects::SignIn.new
      sign_in_page.load
      sign_in_page.sign_in_button.click
    end
  end
end
