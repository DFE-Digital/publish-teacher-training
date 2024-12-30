# frozen_string_literal: true

class SearchCoursesForm < ApplicationForm
  include ActiveModel::Attributes

  attribute :can_sponsor_visa, :boolean
  attribute :subjects
  attribute :send_courses, :boolean
  attribute :applications_open, :boolean
  attribute :study_types
  attribute :qualifications
  attribute :level
  attribute :funding

  attribute :age_group
  attribute :qualification

  def search_params
    attributes
      .symbolize_keys
      .then { |params| params.except(*old_parameters) }
      .then { |params| transform_old_parameters(params) }
      .compact
  end

  def level
    return 'further_education' if old_further_education_parameters?

    super
  end

  def secondary_subjects
    Subject
      .where(type: %w[SecondarySubject ModernLanguagesSubject])
      .where.not(subject_name: ['Modern Languages'])
      .order(:subject_name)
  end

  private

  def transform_old_parameters(params)
    params.tap do
      params[:level] = level
    end
  end

  def old_further_education_parameters?
    age_group == 'further_education' || qualification == ['pgce pgde']
  end

  def old_parameters
    %i[age_group qualification]
  end
end
