# frozen_string_literal: true

class ALevelRowComponent < ViewComponent::Base
  attr_reader :course, :errors

  def initialize(course:, errors: nil)
    super
    @course = course
    @errors = errors
  end

  def inset_text_css_classes
    messages = errors&.values&.flatten

    if messages&.include?('Enter degree requirements')
      'app-inset-text--narrow-border app-inset-text--error'
    else
      'app-inset-text--narrow-border app-inset-text--important'
    end
  end

  def has_errors?
    inset_text_css_classes.include?('app-inset-text--error')
  end
end
