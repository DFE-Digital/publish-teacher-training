module Support
  class UsersController < SupportController
    def index
      @users = filtered_users.page(params[:page] || 1)
    end

    def show
      @providers = providers.order(:provider_name).page(params[:page] || 1)
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

    def user
      @user ||= User.find(params[:id])
    end

    def providers
      RecruitmentCycle.current.providers.where(id: user.providers)
    end

    def filtered_users
      Support::Filter.call(model_data_scope: User.order(:last_name), filter_model: filter)
    end

    def filter
      @filter ||= Support::Providers::Filter.new(params: filter_params)
    end

    def filters
      @filters ||= filter.filters
    end

    def filter_params
      params.permit(:text_search, :page, :commit)
    end
  end
end
