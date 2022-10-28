module Support
  module Users
    class ProvidersController < SupportController
      def show
        user
        @providers = providers.order(:provider_name).page(params[:page] || 1)
        render layout: "user_record"
      end

    private

      def user
        @user ||= User.find(params[:user_id])
      end

      def providers
        recruitment_cycle.providers.where(id: user.providers)
      end
    end
  end
end
