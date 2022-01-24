module PublishInterface
  class UsersController < PublishInterfaceController
    def index
      authorize(provider, :index?)
      @users = provider.users
    end

  private

    def provider
      @provider ||= RecruitmentCycle.current.providers.find_by(provider_code: params[:code])
    end
  end
end
