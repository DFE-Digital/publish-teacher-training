# frozen_string_literal: true

class WhatALevelIsRequiredStore < DfE::Wizard::Store
  delegate :uuid, :subject, :minimum_grade_required, :other_subject, to: :current_step
  delegate :course, to: :wizard

  def save
    if existing_a_level_subject?
      update_existing_a_level_subject_requirement
    else
      add_a_level_subject_requirement
    end

    course.save
  end

  private

  def update_existing_a_level_subject_requirement
    course.a_level_subject_requirements[existing_a_level_subject_index] = a_level_subject_requirements
  end

  def add_a_level_subject_requirement
    course.a_level_subject_requirements << a_level_subject_requirements
  end

  def existing_a_level_subject_index
    @existing_a_level_subject_index ||= course.a_level_subject_requirements.find_index do |a_level_subject_requirement|
      a_level_subject_requirement['uuid'] == uuid
    end
  end

  def existing_a_level_subject?
    existing_a_level_subject_index.present?
  end

  def a_level_subject_requirements
    {
      uuid:,
      subject:,
      other_subject: other_subject.presence,
      minimum_grade_required: minimum_grade_required.presence
    }.compact
  end
end
