# frozen_string_literal: true

class ALevelRowComponent < ViewComponent::Base
  attr_reader :course, :errors

  def initialize(course:, errors: nil)
    super
    @course = course
    @errors = errors&.values&.flatten
  end

  def a_level_requirement_content
    return if @course.a_level_requirements.present?

    I18n.t('publish.providers.courses.description_content.a_levels_not_required')
  end

  def inset_text_css_classes
    'app-inset-text--narrow-border app-inset-text--important'
  end

  def has_errors?
    false
  end
end
