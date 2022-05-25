module API
  module V3
    class ProvidersController < API::V3::ApplicationController
      before_action :build_recruitment_cycle

      def index
        if params[:search].present? && (params[:search].length < 2)
          return render(status: :bad_request)
        end

        build_fields_for_index
        @providers = @recruitment_cycle.providers.includes(:recruitment_cycle)
        @providers = @providers.provider_search(params[:search]) if params[:search].present?

        render jsonapi: @providers.by_name_ascending, class: { Provider: API::V3::SerializableProvider }, fields: @fields
      end

      def show
        code = params.fetch(:code, params[:provider_code])
        @provider = @recruitment_cycle.providers
          .includes(:sites, :courses, courses: [:enrichments, :sites, { site_statuses: [:site], provider: [:recruitment_cycle], subjects: [:financial_incentive] }])
          .find_by!(
            provider_code: code.upcase,
          )

        render jsonapi: @provider,
               class: CourseSerializersService.new.execute,
               include: params[:include],
               fields: { providers: %i[provider_code provider_name courses
                                       recruitment_cycle_year address1 address2
                                       address3 address4 postcode region_code
                                       email website telephone train_with_us
                                       train_with_disability sites
                                       accredited_bodies accredited_body?
                                       can_sponsor_student_visa
                                       can_sponsor_skilled_worker_visa] }
      end

    private

      def build_fields_for_index
        @fields = default_fields_for_index

        return if params[:fields].blank? || params[:fields][:providers].blank?

        @fields[:providers] = params[:fields][:providers].split(",")
      end

      def default_fields_for_index
        {
          providers: %w[provider_name provider_code recruitment_cycle_year],
        }
      end
    end
  end
end
