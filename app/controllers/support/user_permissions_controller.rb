module Support
  class UserPermissionsController < SupportController
    def destroy
      user.remove_access_to(provider)

      redirect_to origin_page, flash: { success: t("support.flash.deleted", resource: flash_resource) }
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

    def flash_resource
      @flash_resource ||= "User permission"
    end
  end
end
