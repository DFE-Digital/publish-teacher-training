# frozen_string_literal: true

class PagesController < ApplicationController
  skip_before_action :authenticate, only: %i[
    accessibility
    performance_dashboard
    privacy
    terms
    add_an_organisation
    add_and_remove_users
    change_an_accredited_provider_relationship
    roll_over_courses_to_a_new_recruitment_cycle
    help_writing_course_descriptions
    how_to_use_this_service
    course_summary_examples
  ]

  def accessibility; end

  def performance_dashboard
    @performance_data = PerformanceDashboardService.call
  end

  def privacy; end

  def terms; end

  def add_an_organisation; end
  def add_and_remove_users; end
  def change_an_accredited_provider_relationship; end
  def roll_over_courses_to_a_new_recruitment_cycle; end
  def help_writing_course_descriptions; end
  def how_to_use_this_service; end
  def course_summary_examples; end
end
