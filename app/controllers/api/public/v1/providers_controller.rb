module API
  module Public
    module V1
      class ProvidersController < API::Public::V1::ApplicationController
        def index
          render jsonapi: paginate(providers),
          include: params[:include], class: API::Public::V1::SerializerService.call, fields: fields
        end

        def show
          code = params.fetch(:code, params[:provider_code])
          provider = recruitment_cycle.providers
                                        .find_by!(
                                          provider_code: code.upcase,
                                        )

          render jsonapi: provider,
                 class: API::Public::V1::SerializerService.call,
                 include: params[:include],
                 fields: fields
        end

      private

        def changed_since
          @changed_since ||= params.dig(:filter, :changed_since)
        end

        def providers
          @providers = recruitment_cycle.providers
          @providers = if sort_by_provider_ascending?
                         @providers.by_name_ascending
                       else
                         @providers.by_name_descending
                       end

          if changed_since.present?
            @providers = @providers.changed_since(changed_since)
          end

          @providers
        end

        def recruitment_cycle
          @recruitment_cycle = RecruitmentCycle.find_by(
            year: params[:recruitment_cycle_year],
          ) || RecruitmentCycle.current_recruitment_cycle
        end

        def fields
          { providers: provider_fields } if provider_fields.present?
        end

        def sort_by_provider_ascending?
          sort_field.include?("name") || !sort_by_provider_descending?
        end

        def sort_by_provider_descending?
          sort_field.include?("-name")
        end

        def sort_field
          @sort_field ||= Set.new(params.dig(:sort)&.split(","))
        end

        def provider_fields
          params.dig(:fields, :providers)&.split(",")
        end
      end
    end
  end
end
