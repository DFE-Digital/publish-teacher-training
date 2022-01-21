module PublishInterface
  module Providers
    class UsersController < PublishInterfaceController
      def index
        authorize(provider, :index?)
        @users = provider.users
      end

    private

      def provider
        @provider ||= recruitment_cycle.providers.find_by(provider_code: params[:provider_code])
      end

      def recruitment_cycle
        @recruitment_cycle ||= RecruitmentCycle.find_by!(year: params.fetch(:year, Settings.current_cycle))
      end
    end
  end
end
