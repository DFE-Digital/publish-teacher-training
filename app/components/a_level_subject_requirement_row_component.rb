# frozen_string_literal: true

class ALevelSubjectRequirementRowComponent < ViewComponent::Base
  attr_reader :a_level_subject_requirement

  MINIMUM_GRADES = %w[A B C D E].freeze
  MAX_GRADE = 'A*'
  IN_WORDS = %w[zero one two three four].freeze # Avoiding the need to add a gem number.in_words for a simple conversion

  def initialize(a_level_subject_requirement)
    super

    @a_level_subject_requirement = a_level_subject_requirement.with_indifferent_access
  end

  def row_value
    "#{subject_name}#{grade}"
  end

  def plural_row_value(count:)
    "#{plural_subject_name(count:)}#{grade}"
  end

  def subject_name
    if other_subject?
      other_subject
    else
      I18n.t("helpers.label.what_a_level_is_required.subject_options.#{subject}").to_s
    end
  end

  def plural_subject_name(count:)
    if other_subject?
      other_subject
    else
      I18n.t("helpers.label.what_a_level_is_required.plural_subject_options.#{subject}", count: IN_WORDS[count]).to_s
    end
  end

  def grade
    return '' if minimum_grade.blank?

    if MINIMUM_GRADES.include?(minimum_grade)
      " - #{I18n.t('a_level_grades.minimum_grade', minimum_grade:)}"
    elsif minimum_grade == MAX_GRADE
      " - #{I18n.t('a_level_grades.max_grade')}"
    else
      " - #{minimum_grade}"
    end
  end

  def other_subject?
    subject == 'other_subject'
  end

  def add_equivalency_suffix(course:, row_value:)
    if course.accept_a_level_equivalency?
      [
        row_value,
        I18n.t('course.a_level_equivalencies.suffix')
      ].join(', ')
    else
      row_value
    end
  end

  private

  def minimum_grade
    a_level_subject_requirement[:minimum_grade_required]
  end

  def subject
    a_level_subject_requirement[:subject]
  end

  def other_subject
    a_level_subject_requirement[:other_subject]
  end
end
