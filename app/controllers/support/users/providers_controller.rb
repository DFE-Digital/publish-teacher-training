# frozen_string_literal: true

module Support
  module Users
    class ProvidersController < ApplicationController
      def show
        user
        @pagy, @providers = pagy(providers.order(:provider_name))
        render layout: 'user_record'
      end

      private

      def user
        @user ||= User.find(params[:user_id])
      end

      def providers
        recruitment_cycle.providers.where(id: user.providers)
      end
    end
  end
end
