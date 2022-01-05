module Support
  class UserPermissionsController < SupportController
    def destroy
      if user.remove_access_to(provider)
        redirect_to origin_page, flash: { success: "#{user_full_name} removed from #{provider.provider_name}" }
      else
        redirect_to origin_page, flash: { success: "Unable to remove #{user_full_name} from #{provider.provider_name}" }
      end
    end

  private

    def user_permission
      @user_permission ||= UserPermission.find(params[:id])
    end

    def user
      @user ||= user_permission.user
    end

    def provider
      @provider ||= user_permission.provider
    end

    def origin_page
      request.referer
    end

    def user_full_name
      [user.first_name, user.last_name].join(" ")
    end
  end
end
