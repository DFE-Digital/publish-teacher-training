# frozen_string_literal: true

class ALevelRowComponent < ViewComponent::Base
  attr_reader :course, :errors

  def initialize(course:, errors: nil)
    super
    @course = course
    @errors = errors&.values&.flatten
  end

  def a_level_not_required_content
    I18n.t('publish.providers.courses.description_content.a_levels_not_required')
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

  def inset_text_css_classes
    'app-inset-text--narrow-border app-inset-text--important'
  end

  def has_errors?
    false
  end
end
