module Support
  class UsersController < ApplicationController
    def index
      @users = provider.users.order(:last_name)
      render layout: "provider_record"
    end

  private

    def provider
      @provider ||= Provider.find(params[:provider_id])
    end
  end
end
