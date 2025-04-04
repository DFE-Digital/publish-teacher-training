# frozen_string_literal: true

module Publish
  module Providers
    module Schools
      class MultipleController < ApplicationController
        def new
          @urn_form = URNForm.new(provider)
        end

        def create
          parsed_urns = URNParser.new(form_params[:values]).call

          @urn_form = URNForm.new(provider, params: { values: parsed_urns.presence })

          if @urn_form.stash
            redirect_to publish_provider_recruitment_cycle_schools_multiple_check_path
          else
            render(:new)
          end
        end

        private

        def provider
          @provider ||= recruitment_cycle.providers.find_by(provider_code: params[:provider_code])
        end

        def form_params
          params.expect(urn_form: [:values])
        end
      end
    end
  end
end
