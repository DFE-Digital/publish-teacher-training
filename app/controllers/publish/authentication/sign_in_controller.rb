# frozen_string_literal: true

module Publish
  module Authentication
    class SignInController < ApplicationController
      skip_before_action :authenticate
      skip_after_action :verify_authorized
      skip_before_action :authorize_provider

      def index
        if AuthenticationService.magic_link?
          redirect_to magic_links_path
        else
          render "index"
        end
      end
    end
  end
end
