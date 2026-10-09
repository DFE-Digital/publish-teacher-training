# frozen_string_literal: true

module Support
  module Providers
    module Schools
      class ChecksController < ApplicationController
        before_action :check_form

        def show; end

        def update
          if @check_form.valid?
            ::ProviderSchools::Creator.call(provider:, gias_school_id: gias_school.id)

            redirect_to support_recruitment_cycle_provider_schools_path
            flash[:success] = t(".added")
          else
            render :show, status: :unprocessable_entity
          end
        end

      private

        def check_form
          @check_form = CheckForm.new(provider:, gias_school:)
        end

        def gias_school
          @gias_school ||= GiasSchool.find(params[:school_id])
        end

        def provider
          @provider ||= Provider.find(params[:provider_id])
        end
      end
    end
  end
end
