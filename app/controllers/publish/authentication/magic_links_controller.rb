# frozen_string_literal: true

module Publish
  module Authentication
    class MagicLinksController < ApplicationController
      layout "application"

      skip_before_action :authenticate
      skip_after_action :verify_authorized
      skip_before_action :authorize_provider

      def new
        @magic_link_form = MagicLinkForm.new
      end

      def create
        @magic_link_form = MagicLinkForm.new(email: magic_link_params[:email])

        if @magic_link_form.submit
          redirect_to magic_link_sent_path
        else
          render :new
        end
      end

      def magic_link_sent; end

    private

      def magic_link_params
        params.expect(publish_authentication_magic_link_form: [:email])
      end
    end
  end
end
