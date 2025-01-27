# frozen_string_literal: true

module Courses
  class SearchForm < ApplicationForm
    include ActiveModel::Attributes

    attribute :can_sponsor_visa, :boolean
    attribute :subjects
    attribute :send_courses, :boolean
    attribute :applications_open, :boolean
    attribute :study_types
    attribute :minimum_degree_required
    attribute :qualifications
    attribute :level
    attribute :funding
    attribute :provider_name
    attribute :location
    attribute :longitude
    attribute :latitude
    attribute :radius

    attribute :age_group
    attribute :qualification
    attribute :degree_required
    attribute :university_degree_status, :boolean
    attribute :'provider.provider_name'

    def search_params
      attributes
        .symbolize_keys
        .then { |params| params.except(*old_parameters) }
        .then { |params| transform_old_parameters(params) }
        .compact
    end

    def provider_name
      old_provider_name_parameter.presence || super
    end

    def level
      return 'further_education' if old_further_education_parameters?

      super
    end

    def minimum_degree_required
      return super if degree_required.nil? && university_degree_status.nil?

      university_degree_status_transformation || degree_required_transformation || super
    end

    def secondary_subjects
      Subject
        .where(type: %w[SecondarySubject ModernLanguagesSubject])
        .where.not(subject_name: ['Modern Languages'])
        .order(:subject_name)
    end

    def primary_subjects
      Subject.where(type: 'PrimarySubject').order(:subject_name)
    end

    private

    def transform_old_parameters(params)
      params.tap do
        params[:level] = level
        params[:minimum_degree_required] = minimum_degree_required
        params[:provider_name] = provider_name
      end
    end

    DEGREE_REQUIRED_OLD_PARAMETERS = {
      'show_all_courses' => 'two_one',
      'two_two' => 'two_two',
      'third_class' => 'third_class',
      'not_required' => 'pass'
    }.freeze

    def degree_required_transformation
      DEGREE_REQUIRED_OLD_PARAMETERS[degree_required]
    end

    def university_degree_status_transformation
      return if university_degree_status.nil?

      'no_degree_required' unless university_degree_status
    end

    def old_further_education_parameters?
      age_group == 'further_education' || qualification == ['pgce pgde']
    end

    def old_provider_name_parameter
      send(:'provider.provider_name')
    end

    def old_parameters
      %i[age_group qualification degree_required university_degree_status provider.provider_name]
    end
  end
end
