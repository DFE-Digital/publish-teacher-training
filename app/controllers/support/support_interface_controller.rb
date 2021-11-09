module Support
  class SupportInterfaceController < ApplicationController
    before_action :authenticate

  private

    def authenticate
      redirect_to sign_in_path if !current_user&.admin?
    end
  end
end
