module Support
  class UsersController < SupportController
    def index
      recruitment_cycle
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
        redirect_to support_recruitment_cycle_users_path(params[:recruitment_cycle_year])
      else
        render :new
      end
    end

    def edit
      user
    end

    def update
      if user.update(update_user_params)
        redirect_to support_recruitment_cycle_user_path(params[:recruitment_cycle_year], user), flash: { success: t("support.flash.updated", resource: "User") }
      else
        render :edit
      end
    end

    def destroy
      if user.discard
        redirect_to support_recruitment_cycle_users_path(params[:recruitment_cycle_year]), flash: { success: "User successfully deleted" }
      else
        redirect_to support_recruitment_cycle_users_path(params[:recruitment_cycle_year]), flash: { success: "This user has already been deleted" }
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

    def filtered_users
      Support::Filter.call(model_data_scope: User.order(:last_name), filter_params:)
    end

    def filter_params
      @filter_params ||= params.except(:commit, :recruitment_cycle_year).permit(:text_search, :page, :commit, user_type: [])
    end
  end
end
