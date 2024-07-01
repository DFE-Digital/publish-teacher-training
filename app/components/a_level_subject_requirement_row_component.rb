# frozen_string_literal: true

class ALevelSubjectRequirementRowComponent < ViewComponent::Base
  attr_reader :a_level_subject_requirement

  MINIMUM_GRADES = %w[A B C D E].freeze
  MAX_GRADE = 'A*'

  def initialize(a_level_subject_requirement)
    super

    @a_level_subject_requirement = a_level_subject_requirement
  end

  def row_value
    "#{subject_name}#{grade_display(minimum_grade)}"
  end

  def subject_name
    if other_subject?
      other_subject
    else
      I18n.t("helpers.label.what_a_level_is_required.subject_options.#{subject}").to_s
    end
  end

  private

  def grade_display(minimum_grade)
    return '' if minimum_grade.blank?

    if MINIMUM_GRADES.include?(minimum_grade)
      " - #{I18n.t('a_level_grades.minimum_grade', minimum_grade:)}"
    elsif minimum_grade == MAX_GRADE
      " - #{I18n.t('a_level_grades.max_grade')}"
    else
      " - #{minimum_grade}"
    end
  end

  def minimum_grade
    a_level_subject_requirement[:minimum_grade_required]
  end

  def subject
    a_level_subject_requirement[:subject]
  end

  def other_subject
    a_level_subject_requirement[:other_subject]
  end

  def other_subject?
    subject == 'other_subject'
  end
end
