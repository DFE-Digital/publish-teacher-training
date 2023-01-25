module Publish
  class UsersEditCheckController < PublishController
    before_action :authorize_provider

    def show
      @user_form = UserForm.new(current_user, user)
    end

    def update
      @user_form = UserForm.new(current_user, user)
      return unless @user_form.save!

      UserAssociationsService::Create.call(user: @user_form.model, provider:) if @user_form.model.providers.exclude?(provider)
      redirect_to publish_provider_user_path(id: params[:user_id])
      flash[:success] = "User updated"
    end

  private

    def user
      @user = User.find(params[:user_id])
    end

    def authorize_provider
      authorize(provider)
    end
  end
end
