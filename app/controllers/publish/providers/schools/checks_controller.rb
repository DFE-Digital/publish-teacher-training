# frozen_string_literal: true

module Publish
  module Providers
    module Schools
      class ChecksController < ApplicationController
        before_action :check_form

        def show; end

        def update
          if @check_form.valid?
            ::ProviderSchools::Creator.call(provider:, gias_school_id: gias_school.id)

            redirect_to publish_provider_recruitment_cycle_schools_path,
                        flash: { success_with_body: { title: t(".added"), body: gias_school.name } }
          else
            render :show, status: :unprocessable_entity
          end
        end

      private

        def check_form
          @check_form = ::ProviderSchools::CheckForm.new(provider:, gias_school:)
        end

        def gias_school
          @gias_school ||= GiasSchool.find(params[:school_id])
        end
      end
    end
  end
end
