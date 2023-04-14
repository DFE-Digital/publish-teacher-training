# frozen_string_literal: true

class PagesController < ApplicationController
  skip_before_action :authenticate, only: %i[
    accessibility
    performance_dashboard
    privacy
    terms
    add_an_organisation
    add_and_remove_users
    how_to_use_this_service
    course_summary_examples
    writing_descriptions_for_publish_teacher_training_courses
  ]

  def accessibility; end

  def performance_dashboard
    @performance_data = PerformanceDashboardService.call
  end

  def privacy; end

  def terms; end

  def add_an_organisation; end
  def add_and_remove_users; end
  def how_to_use_this_service; end
  def course_summary_examples; end
  def writing_descriptions_for_publish_teacher_training_courses; end
end
