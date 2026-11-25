# frozen_string_literal: true

module Publish
  module Providers
    module Schools
      class ChecksController < ApplicationController
        include ReturnToSupport
        include ReturnPaths::Schools

        before_action :check_form

        def show; end

        def update
          if @check_form.valid?
            ::ProviderSchools::Creator.call(provider:, gias_school_id: gias_school.id)

            if returning_to_support?
              schools_added_message([gias_school])
            else
              flash[:success_with_body] = { title: t(".added"), body: gias_school.name }
            end

            redirect_to return_path
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
