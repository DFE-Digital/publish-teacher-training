# frozen_string_literal: true

module API
  module Public
    module V1
      module Providers
        class LocationsController < API::Public::V1::ApplicationController
          def index
            meta = if FeatureFlag.active?(:course_publishing_uses_new_school_model)
                     { count: locations.count("provider_school.id") }
                   else
                     { count: locations.count("site.id") }
                   end

            render jsonapi: locations,
                   include: include_param,
                   meta:,
                   class: API::Public::V1::SerializerService.call
          end

        private

          def locations
            @locations ||= if FeatureFlag.active?(:course_publishing_uses_new_school_model)
                             provider.schools
                           else
                             provider.sites
                           end
          end

          def provider
            @provider ||= recruitment_cycle.providers.find_by!(provider_code: params[:provider_code])
          end

          def include_param
            params.fetch(:include, "")
          end
        end
      end
    end
  end
end
