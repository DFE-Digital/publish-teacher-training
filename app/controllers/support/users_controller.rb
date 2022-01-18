module Support
  class UsersController < SupportController
    def index
      @users = filtered_users.page(params[:page] || 1)
    end

    def show
      user
      render layout: "user_record"
    end

    def new
      @user = User.new
    end

    def create
      @user = User.new(user_params)
      if @user.save
        redirect_to support_users_path
      else
        render :new
      end
    end

    def edit
      user
    end

    def providers
      user
      @providers = fetch_providers.order(:provider_name).page(params[:page] || 1)
      render layout: "user_record"
    end

    def update
      if user.update(update_user_params)
        redirect_to support_user_path(user), flash: { success: t("support.flash.updated", resource: "User") }
      else
        render :edit
      end
    end

    def destroy
      if user.discard
        redirect_to support_users_path, flash: { success: "User successfully deleted" }
      else
        redirect_to support_users_path, flash: { success: "This user has already been deleted" }
      end
    end

  private

    def user_params
      params.require(:user).permit(:first_name, :last_name, :email).merge(state: "new")
    end

    def update_user_params
      params.require(:user).permit(:first_name, :last_name, :email, :admin)
    end

    def user
      @user ||= User.find(params[:id])
    end

    def fetch_providers
      RecruitmentCycle.current.providers.where(id: user.providers)
    end

    def filtered_users
      Support::Filter.call(model_data_scope: User.order(:last_name), filter_params: filter_params)
    end

    def filter_params
      @filter_params ||= params.except(:commit).permit(:text_search, :page, :commit, user_type: [])
    end
  end
end
