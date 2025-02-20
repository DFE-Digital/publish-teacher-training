# frozen_string_literal: true

module Courses
  class SearchForm < ApplicationForm
    include ActiveModel::Attributes

    # Search parameters #
    attribute :applications_open, :boolean
    attribute :can_sponsor_visa, :boolean
    attribute :funding
    attribute :latitude
    attribute :level
    attribute :location
    attribute :longitude
    attribute :minimum_degree_required
    attribute :engineers_teach_physics
    attribute :start_date
    attribute :order
    attribute :provider_code
    attribute :provider_name
    attribute :qualifications
    attribute :radius
    attribute :send_courses, :boolean
    attribute :study_types
    attribute :subject_code
    attribute :subject_name
    attribute :subjects

    # Coordinates #
    attribute :country
    attribute :formatted_address
    attribute :types

    # Old parameters #
    attribute :'provider.provider_name'
    attribute :age_group
    attribute :degree_required
    attribute :qualification
    attribute :sortby
    attribute :university_degree_status, :boolean

    attr_accessor :providers_cache, :subjects_cache

    delegate :primary_subjects, :primary_subject_codes, :secondary_subjects, :secondary_subject_codes, :all_subjects, to: :subjects_cache
    delegate :providers_list, to: :providers_cache

    def initialize(attributes = {})
      super

      @subjects_cache = SubjectsCache.new
      @providers_cache = ProvidersCache.new
    end

    def search_params
      attributes
        .symbolize_keys
        .then { |params| params.except(*old_parameters) }
        .then { |params| transform_old_parameters(params) }
        .then { |params| inject_defaults(params) }
        .compact_blank
    end

    def provider_name
      old_provider_name_parameter.presence || super
    end

    def level
      return 'further_education' if old_further_education_parameters?

      super
    end

    def order
      return super if sortby.blank?

      sort_by_transformation || super
    end

    def minimum_degree_required
      return super if degree_required.nil? && university_degree_status.nil?

      university_degree_status_transformation || degree_required_transformation || super
    end

    OrderingOption = Struct.new(:id, :name, keyword_init: true)

    def ordering_options
      [
        OrderingOption.new(
          id: 'course_name_ascending',
          name: I18n.t('helpers.label.courses_search_form.ordering.options.course_name_ascending')
        ),
        OrderingOption.new(
          id: 'course_name_descending',
          name: I18n.t('helpers.label.courses_search_form.ordering.options.course_name_descending')
        ),
        OrderingOption.new(
          id: 'provider_name_ascending',
          name: I18n.t('helpers.label.courses_search_form.ordering.options.provider_name_ascending')
        ),
        OrderingOption.new(
          id: 'provider_name_descending',
          name: I18n.t('helpers.label.courses_search_form.ordering.options.provider_name_descending')
        )
      ]
    end

    RadiusOption = Struct.new(:value, :name, keyword_init: true)
    RADIUS_VALUES = [1, 5, 10, 15, 20, 25, 50, 100, 200].freeze
    DEFAULT_RADIUS = 10
    LARGE_RADIUS = 50

    def radius_options
      RADIUS_VALUES.map do |value|
        RadiusOption.new(
          value:,
          name: I18n.t('helpers.label.courses_search_form.radius_options.miles', count: value)
        )
      end
    end

    def radius
      return super if super.present?

      types&.include?('administrative_area_level_2') ? LARGE_RADIUS : DEFAULT_RADIUS
    end

    PHYSICS_SUBJECT_CODE = 'F3'

    def search_for_physics?
      PHYSICS_SUBJECT_CODE.in?(Array(subjects)) || subject_code == PHYSICS_SUBJECT_CODE
    end

    def engineers_teach_physics
      return unless search_for_physics?

      super
    end

    private

    def transform_old_parameters(params)
      params.tap do
        params[:level] = level
        params[:minimum_degree_required] = minimum_degree_required
        params[:provider_name] = provider_name
        params[:order] = order
      end
    end

    def inject_defaults(params)
      params.tap do
        params[:radius] = (radius if location.present?)

        params[:engineers_teach_physics] = nil unless search_for_physics?
      end
    end

    DEGREE_REQUIRED_OLD_VALUES_TO_NEW_VALUES = {
      'show_all_courses' => 'two_one',
      'two_two' => 'two_two',
      'third_class' => 'third_class',
      'not_required' => 'pass'
    }.freeze
    private_constant :DEGREE_REQUIRED_OLD_VALUES_TO_NEW_VALUES

    def degree_required_transformation
      DEGREE_REQUIRED_OLD_VALUES_TO_NEW_VALUES[degree_required]
    end

    SORT_BY_OLD_VALUES_TO_NEW_VALUES = {
      'course_asc' => 'course_name_ascending',
      'course_desc' => 'course_name_descending',
      'provider_asc' => 'provider_name_ascending',
      'provider_desc' => 'provider_name_descending'
    }.freeze
    private_constant :SORT_BY_OLD_VALUES_TO_NEW_VALUES

    def sort_by_transformation
      SORT_BY_OLD_VALUES_TO_NEW_VALUES[sortby]
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
      %i[age_group qualification degree_required university_degree_status provider.provider_name sortby]
    end
  end
end
