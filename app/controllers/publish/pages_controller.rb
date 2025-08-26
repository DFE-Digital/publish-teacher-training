# frozen_string_literal: true

module Publish
  class PagesController < ApplicationController
    skip_after_action :verify_authorized
    skip_before_action :authorize_provider
    skip_before_action :authenticate
    def accessibility; end

    def performance_dashboard
      @performance_data = PerformanceDashboardService.call
    end

    def privacy; end

    def terms; end

    def add_an_organisation; end
    def add_and_remove_users; end
    def change_an_accredited_provider_relationship; end
    def add_schools_and_study_sites; end
    def roll_over_courses_to_a_new_recruitment_cycle; end
    def help_writing_course_descriptions; end
    def course_summary_examples; end
    def how_to_use_this_service; end
    def add_course_information; end
  end
end
