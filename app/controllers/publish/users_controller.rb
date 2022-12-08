module Publish
  class UsersController < PublishController
    before_action :authorize_provider

    def index
      @users = provider.users
    end

    def show
      provider_user
    end

    def new
      @user_form = UserForm.new(current_user, user)
      @user_form.clear_stash
    end

    def create
      @user_form = UserForm.new(current_user, user, params: user_params)
      if @user_form.stash
        redirect_to publish_provider_check_user_path(provider_code: params[:provider_code])
      else
        render(:new)
      end
    end

  private

    def authorize_provider
      authorize(provider)
    end

    def cycle_year
      session[:cycle_year] || params[:recruitment_cycle_year] || params[:year] || Settings.current_recruitment_cycle_year
    end

    def user
      User.find_or_initialize_by(email: params.dig(:publish_user_form, :email))
    end

    def user_params
      params.require(:publish_user_form).permit(:first_name, :last_name, :email).except(:code, :authenticity_token)
    end

    def provider_user
      @provider_user ||= provider.users.find(params[:id])
    end
  end
end
