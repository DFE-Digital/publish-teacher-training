module Publish
  class UsersController < PublishController
    def index
      authorize(provider)

      @users = provider.users
    end

    def new
      authorize(provider)
      @user_form = UserForm.new(current_user, user)
      @user_form.clear_stash
    end

    def create
      authorize(provider)

      @user_form = UserForm.new(current_user, user, params: user_params)
      if @user_form.stash
        redirect_to publish_provider_check_user_path(provider_code: params[:code])
      else
        render(:new)
      end
    end

    def cycle_year
      session[:cycle_year] || params[:recruitment_cycle_year] || params[:year] || Settings.current_recruitment_cycle_year
    end

    def user
      User.find_or_initialize_by(email: params.dig(:publish_user_form, :email))
    end

    def user_params
      params.require(:publish_user_form).permit(:first_name, :last_name, :email, :code, :authenticity_token)
    end
  end
end
