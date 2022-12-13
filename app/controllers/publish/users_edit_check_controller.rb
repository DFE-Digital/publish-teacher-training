module Publish
  class UsersEditCheckController < PublishController
    before_action :authorize_provider

    def show
      @user_form = UserForm.new(current_user, user)
    end

    def create
      @user_form = UserForm.new(current_user, user, params: user_params)
      if @user_form.stash
        redirect_to publish_provider_user_edit_check_path(provider_code: params[:provider_code])
      else
        render(:edit) # #todo fix this
      end
    end

    def update
      @user_form = UserForm.new(current_user, user)
      if @user_form.save!
        UserAssociationsService::Create.call(user: @user_form.model, provider:) if @user_form.model.providers.exclude?(provider)
        authorize(provider)
        redirect_to publish_provider_user_path(id: params[:user_id])
        flash[:success] = "User updated"
      end
    end

    def user
      @user = User.find(params[:user_id])
    end

    def user_params
      params.require(:publish_user_form).permit(:first_name, :last_name, :email).except(:code, :authenticity_token)
    end

    def authorize_provider
      authorize(provider)
    end
  end
end
