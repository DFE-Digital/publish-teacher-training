# frozen_string_literal: true

module Support
  module Providers
    module Schools
      class ChecksController < ApplicationController
        before_action :new_form

        def show; end

        def update
          if @school_form.save!
            redirect_to support_recruitment_cycle_provider_schools_path
            flash[:success] = t('.added')
          else
            render :show
          end
        end

        private

        def new_form
          @school_form = SchoolForm.new(provider, site, params: { gias_school_id: params[:school_id] })
        end

        def site
          @site ||= begin
            gias_school = GiasSchool.find(params[:school_id])
            @provider.sites.school.build(gias_school.school_attributes)
          end
        end

        def provider
          @provider ||= Provider.find(params[:provider_id])
        end
      end
    end
  end
end
