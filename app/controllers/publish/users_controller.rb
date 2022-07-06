module Publish
  class UsersController < PublishController
    def index
      authorize(provider)

      @users = provider.users
    end

    def cycle_year
      session[:cycle_year] || params[:recruitment_cycle_year] || params[:year] || Settings.current_recruitment_cycle_year
    end
  end
end
