# frozen_string_literal: true

class SearchCoursesForm < ApplicationForm
  include ActiveModel::Attributes

  attribute :can_sponsor_visa, :boolean
  attribute :subjects
  attribute :send_courses, :boolean
  attribute :applications_open, :boolean
  attribute :study_types
  attribute :qualifications
  attribute :further_education, :boolean
  attribute :funding

  def search_params
    attributes.symbolize_keys.compact
  end

  def secondary_subjects
    Subject
      .where(type: %w[SecondarySubject ModernLanguagesSubject])
      .where.not(subject_name: ['Modern Languages'])
      .order(:subject_name)
  end
end
