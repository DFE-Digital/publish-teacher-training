# frozen_string_literal: true

module Support
  module Providers
    module Schools
      class MultipleController < ApplicationController
        def new
        end

        def create

          else
            render(:new)
          end
        end

        private

        def provider
          @provider ||= recruitment_cycle.providers.find(params[:provider_id])
        end

        def form_params
        end
      end
    end
  end
end
