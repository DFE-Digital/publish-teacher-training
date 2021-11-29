module Support
  class SupportController < ApplicationController
    layout "support"
    before_action :check_user_is_admin

  private

    def check_user_is_admin
      if !current_user.admin?
        flash[:warning] = "User is not an admin"
        redirect_to sign_in_path
      end
    end
  end
end
