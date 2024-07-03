# frozen_string_literal: true

class ALevelCourseValidator < ActiveModel::Validator
  def validate(record)
    return record.errors.add(:a_level_requirements, :blank) if record.a_level_requirements.nil?

    return if record.a_level_requirements.blank? # No A level required

    return record.errors.add(:a_level_subject_requirements, :blank) if record.a_level_subject_requirements.blank?

    return record.errors.add(:accept_pending_a_level, :blank) if record.accept_pending_a_level.nil?

    record.errors.add(:accept_a_level_equivalency, :blank) if record.accept_a_level_equivalency.nil?
  end
end
