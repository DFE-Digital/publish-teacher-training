# frozen_string_literal: true

module API
  module Public
    module V1
      class ProvidersController < API::Public::V1::ApplicationController
        def index
          render jsonapi: paginate(providers),
                 include: params[:include],
                 meta: { count: providers.count('provider.id') }, class: API::Public::V1::SerializerService.call, fields:
        end

        def show
          code = params.fetch(:code, params[:provider_code])
          provider = recruitment_cycle.providers
                                      .find_by!(
                                        provider_code: code.upcase
                                      )

          render jsonapi: provider,
                 class: API::Public::V1::SerializerService.call,
                 include: params[:include],
                 fields:
        end

        private

        def provider_name
          @provider_name ||= params.dig(:filter, :provider_name) if params.dig(:filter, :provider_name)&.length&.> 2
        end

        def updated_since
          @updated_since ||= params.dig(:filter, :updated_since)
        end

        def provider_types
          return [] if params.dig(:filter, :provider_type).blank?
          return [] unless params.dig(:filter, :provider_type).is_a?(String)

          params.dig(:filter, :provider_type).split(',')
        end

        def region_codes
          return [] if params.dig(:filter, :region_code).blank?
          return [] unless params.dig(:filter, :region_code).is_a?(String)

          params.dig(:filter, :region_code).split(',')
        end

        def can_sponsor_skilled_worker_visa?
          @can_sponsor_skilled_worker_visa ||= params.dig(:filter, :can_sponsor_skilled_worker_visa)&.to_s&.downcase == 'true'
        end

        def can_sponsor_student_visa?
          @can_sponsor_student_visa ||= params.dig(:filter, :can_sponsor_student_visa)&.to_s&.downcase == 'true'
        end

        def is_accredited_provider?
          @is_accredited_provider ||= params.dig(:filter, :is_accredited_provider)&.to_s&.downcase == 'true'
        end

        def providers
          @providers = recruitment_cycle.providers

          @providers = @providers.provider_name_search(provider_name) if provider_name.present?
          @providers = @providers.changed_since(updated_since) if updated_since.present?
          @providers = @providers.with_provider_types(provider_types) if provider_types.present?
          @providers = @providers.with_region_codes(region_codes) if region_codes.present?
          @providers = @providers.with_can_sponsor_skilled_worker_visa(true) if can_sponsor_skilled_worker_visa?
          @providers = @providers.with_can_sponsor_student_visa(true) if can_sponsor_student_visa?
          @providers = @providers.accredited_provider if is_accredited_provider?

          @providers = if sort_by_provider_ascending?
                         @providers.by_name_ascending
                       else
                         @providers.by_name_descending
                       end

          @providers
        end

        def recruitment_cycle
          @recruitment_cycle = RecruitmentCycle.find_by(
            year: params[:recruitment_cycle_year]
          ) || RecruitmentCycle.current_recruitment_cycle
        end

        def fields
          { providers: provider_fields } if provider_fields.present?
        end

        def sort_by_provider_ascending?
          sort_field.include?('name') || !sort_by_provider_descending?
        end

        def sort_by_provider_descending?
          sort_field.include?('-name')
        end

        def sort_field
          @sort_field ||= Set.new(params[:sort]&.split(','))
        end

        def provider_fields
          params.dig(:fields, :providers)&.split(',')
        end
      end
    end
  end
end
