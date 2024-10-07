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

  def row_value_with_hint
    "#{subject_name}#{grade(short_description: true)}"
  end

  def plural_row_value_with_hint(count:)
    "#{plural_subject_name(count:)}#{grade(short_description: true)}"
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
      I18n.t("helpers.label.what_a_level_is_required.plural_subject_options.#{subject}", count_in_words: IN_WORDS[count]).to_s
    end
  end

  def grade(short_description: false)
    return '' if minimum_grade.blank?

    " - #{grade_description(short_description:)}"
  end

  def grade_description(short_description:)
    return I18n.t('a_level_grades.max_grade').to_s if max_grade?

    if minimum_grade? && short_description.present?
      I18n.t('a_level_grades.minimum_grade', minimum_grade:).to_s
    elsif minimum_grade? && short_description.blank?
      I18n.t('a_level_grades.minimum_grade_or_above', minimum_grade:).to_s
    else
      minimum_grade.to_s
    end
  end

  def minimum_grade?
    MINIMUM_GRADES.include?(minimum_grade)
  end

  def max_grade?
    minimum_grade == MAX_GRADE
  end

  def other_subject?
    subject == 'other_subject'
  end

  def grade_hint
    if minimum_grade?
      "#{I18n.t('course.a_level_equivalencies.or_above')} #{I18n.t('course.a_level_equivalencies.suffix')}"
    else
      I18n.t('course.a_level_equivalencies.suffix')
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
