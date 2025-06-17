# frozen_string_literal: true

module Publish
  module Authentication
    class SignInController < ApplicationController
      include Unauthenticated

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
