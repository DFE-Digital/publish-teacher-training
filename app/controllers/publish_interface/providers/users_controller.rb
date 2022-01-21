module PublishInterface
  module Providers
    class UsersController < PublishInterfaceController
      def index
        cycle_year = params.fetch(:year, Settings.current_cycle)
        @recruitment_cycle = RecruitmentCycle.find_by!(year: cycle_year)

        @provider = @recruitment_cycle.providers.find_by(provider_code: params[:provider_code])

        @users = @provider.users
      end
    end
  end
end
