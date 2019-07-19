module API
  module V2
    class ProvidersController < API::V2::ApplicationController
      before_action :get_user, if: -> { params[:user_id].present? }
      before_action :build_recruitment_cycle
      before_action :build_provider, except: :index

      deserializable_resource :course,
                              only: :update,
                              class: API::V2::DeserializableProvider

      def index
        authorize Provider
        providers = policy_scope(@recruitment_cycle.providers)
                      .include_courses_counts
        providers = providers.where(id: @user.providers) if @user.present?

        render jsonapi: providers.in_order,
               fields: { providers: %i[provider_code provider_name courses
                                       recruitment_cycle_year] }
      end

      def show
        authorize @provider, :show?

        render jsonapi: @provider, include: params[:include]
      end

    private

      def build_recruitment_cycle
        @recruitment_cycle = RecruitmentCycle.find_by(
          year: params[:recruitment_cycle_year]
        ) || RecruitmentCycle.current_recruitment_cycle
      end

      def build_provider
        code = params.fetch(:code, params[:provider_code])
        @provider = @recruitment_cycle.providers
                      .includes(:latest_published_enrichment)
                      .find_by!(
                        provider_code: code.upcase
                      )
      end

      def get_user
        @user = User.find(params[:user_id])
      end
    end
  end
end
