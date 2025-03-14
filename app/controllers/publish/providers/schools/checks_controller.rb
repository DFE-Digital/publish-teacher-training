# frozen_string_literal: true

module Publish
  module Providers
    module Schools
      class ChecksController < ApplicationController
        before_action :new_form

        def show; end

        def update
          if @school_form.save!
            redirect_to publish_provider_recruitment_cycle_schools_path
            flash[:success] = t('publish.providers.schools.added')
          else
            render template: 'publish/providers/schools/new'
          end
        end

        private

        def new_form
          @school_form = ::Support::SchoolForm.new(provider, site)
        end

        def site
          @site ||= provider.sites.build
        end
      end
    end
  end
end
