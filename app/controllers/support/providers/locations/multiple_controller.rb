# frozen_string_literal: true

module Support
  module Providers
    module Locations
      class MultipleController < SupportController
        def new
          @multiple_locations_form = MultipleLocationsForm.new(current_user, user)
          provider
        end

        def edit
          @site = Site.new
          provider
          @multiple_locations_form = MultipleLocationsForm.new(current_user, user)
        end

        def create
          provider
          @multiple_locations_form = MultipleLocationsForm.new(current_user, user, params: user_params)
          if @multiple_locations_form.stash
            redirect_to support_recruitment_cycle_provider_locations_multiple_new_path(position: 1)
          else
            render(:new)
          end
        end

        def provider
          @provider ||= recruitment_cycle.providers.find(params[:provider_id])
        end

        def user
          User.find_or_initialize_by(email: params.dig(:support_multiple_locations_form, :email)&.downcase) # will change in follow up PR
        end

        def user_params
          params.require(:support_multiple_locations_form).permit(:location_details)
        end
      end
    end
  end
end
