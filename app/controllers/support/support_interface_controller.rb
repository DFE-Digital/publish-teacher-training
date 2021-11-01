module Support
  class SupportInterfaceController < ApplicationController
    before_action :authenticate_support_user

  private

    def authenticate_support_user
      redirect_to sign_in_path if !current_user.admin?
    end
  end
end
