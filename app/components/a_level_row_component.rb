# frozen_string_literal: true

class ALevelRowComponent < ViewComponent::Base
  attr_reader :course, :errors

  delegate :provider, to: :course
  delegate :provider_code, to: :provider
  include ViewHelper

  A_LEVEL_ERRORS = %i[
    a_level_subject_requirements
    accept_pending_a_level
    accept_a_level_equivalency
  ].freeze

  def initialize(course:, errors: nil)
    super
    @course = course
    @errors = errors
  end

  def a_level_subject_row_content(a_level_subject_requirement)
    a_level_subject_requirement_row_component = ALevelSubjectRequirementRowComponent.new(a_level_subject_requirement)

    a_level_subject_requirement_row_component.add_equivalency_suffix(
      course:,
      row_value: a_level_subject_requirement_row_component.row_value
    )
  end

  def pending_a_level_summary_content
    I18n.t("course.consider_pending_a_level.row.#{@course.accept_pending_a_level?}") unless @course.accept_pending_a_level.nil?
  end

  def a_level_equivalency_summary_content
    I18n.t("course.a_level_equivalencies.row.#{@course.accept_a_level_equivalency?}") unless @course.accept_a_level_equivalency.nil?
  end

  def has_errors?
    @errors.present? && a_level_errors.any?
  end

  def a_level_errors
    Array(@errors.keys & A_LEVEL_ERRORS)
  end

  def wizard_step(a_level_error)
    {
      a_level_subject_requirements: :what_a_level_is_required,
      accept_pending_a_level: :consider_pending_a_level,
      accept_a_level_equivalency: :a_level_equivalencies
    }.with_indifferent_access[a_level_error]
  end

  def minimum_a_level_completed?
    course.a_level_subject_requirements.present?
  end
end
