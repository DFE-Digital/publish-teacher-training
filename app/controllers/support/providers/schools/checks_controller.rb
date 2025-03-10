# frozen_string_literal: true

module Support
  module Providers
    module Schools
      class ChecksController < ApplicationController
        before_action :new_form

        def show; end

        def update
          if @school_form.save!
            flash[:success] = t('support.providers.schools.added')
          else
            render template: 'support/schools/new'
          end
        end

        private

        def new_form
          @school_form = SchoolForm.new(provider, site)
        end

        def site
          @site ||= provider.sites.build
        end

        def provider
          @provider ||= Provider.find(params[:provider_id])
        end
      end
    end
  end
end
