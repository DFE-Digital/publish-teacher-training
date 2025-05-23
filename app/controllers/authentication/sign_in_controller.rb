# frozen_string_literal: true

module Authentication
  class SignInController < ApplicationController
    skip_before_action :authenticate

    def index
      if AuthenticationService.magic_link?
        redirect_to magic_links_path
      else
        render "index"
      end
    end
  end
end
