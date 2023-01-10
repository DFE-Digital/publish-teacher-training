module Publish
  class UsersCheckController < PublishController
    before_action :authorize_provider

    def show
      @user_form = UserForm.new(current_user, user)
    end

    def update
      @user_form = UserForm.new(current_user, user)
      if @user_form.save!
        UserAssociationsService::Create.call(user: @user_form.model, provider:) if @user_form.model.providers.exclude?(provider)
        redirect_to publish_provider_users_path(params[:provider_code])
        flash[:success] = "User added"
      end
    end

  private

    def authorize_provider
      authorize(provider)
    end

    def user
      User.find_or_initialize_by(email: params.dig(:publish_user_form, :email)&.downcase)
    end
  end
end
