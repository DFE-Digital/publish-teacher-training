# frozen_string_literal: true

module Courses
  class SearchForm < ApplicationForm
    # Search parameters #
    attribute :applications_open, :boolean
    attribute :can_sponsor_visa, :boolean
    attribute :engineers_teach_physics
    attribute :funding
    attribute :latitude
    attribute :level
    attribute :location
    attribute :longitude
    attribute :minimum_degree_required
    attribute :order
    attribute :provider_code
    attribute :provider_name
    attribute :qualifications
    attribute :radius
    attribute :send_courses, :boolean
    attribute :start_date
    attribute :study_types
    attribute :subject_code
    attribute :subject_name
    attribute :subjects

    # Coordinates #
    attribute :country
    attribute :formatted_address
    attribute :types

    # Old parameters #
    attribute :age_group
    attribute :degree_required
    attribute :lq
    attribute :'provider.provider_name'
    attribute :qualification
    attribute :sortby
    attribute :study_type
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
      return "further_education" if old_further_education_parameters?

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
          id: "course_name_ascending",
          name: I18n.t("helpers.label.courses_search_form.ordering.options.course_name_ascending"),
        ),
        OrderingOption.new(
          id: "course_name_descending",
          name: I18n.t("helpers.label.courses_search_form.ordering.options.course_name_descending"),
        ),
        OrderingOption.new(
          id: "provider_name_ascending",
          name: I18n.t("helpers.label.courses_search_form.ordering.options.provider_name_ascending"),
        ),
        OrderingOption.new(
          id: "provider_name_descending",
          name: I18n.t("helpers.label.courses_search_form.ordering.options.provider_name_descending"),
        ),
      ]
    end

    RadiusOption = Struct.new(:value, :name, keyword_init: true)
    RADIUS_VALUES = [1, 5, 10, 15, 20, 25, 50, 100, 200].freeze
    DEFAULT_RADIUS = 50
    SMALL_RADIUS = 10
    LONDON_RADIUS = 15

    def radius_options
      RADIUS_VALUES.map do |value|
        RadiusOption.new(
          value:,
          name: I18n.t("helpers.label.courses_search_form.radius_options.miles", count: value),
        )
      end
    end

    def radius
      return super if super.present?

      if london?
        LONDON_RADIUS
      elsif locality?
        SMALL_RADIUS
      else
        DEFAULT_RADIUS
      end
    end

    def london?
      formatted_address == "London, UK"
    end

    def locality?
      # @see https://developers.google.com/maps/documentation/geocoding/requests-geocoding#Types
      small_radius = %w[postal_code street_address route sublocality locality]
      types && (types & small_radius).present?
    end

    PHYSICS_SUBJECT_CODE = "F3"

    def search_for_physics?
      PHYSICS_SUBJECT_CODE.in?(Array(subjects)) || subject_code == PHYSICS_SUBJECT_CODE
    end

    def engineers_teach_physics
      return unless search_for_physics?

      super
    end

    def location
      lq.presence || super
    end

    def study_types
      study_type.presence || super
    end

    def qualifications
      return old_qualification_transformation if qualification.present?

      super
    end

  private

    def transform_old_parameters(params)
      params.tap do
        params[:level] = level
        params[:minimum_degree_required] = minimum_degree_required
        params[:order] = order
        params[:provider_name] = provider_name
        params[:study_types] = study_types
        params[:qualifications] = qualifications
      end
    end

    def inject_defaults(params)
      params.tap do
        params[:radius] = (radius if location.present?)

        params[:engineers_teach_physics] = nil unless search_for_physics?
      end
    end

    DEGREE_REQUIRED_OLD_VALUES_TO_NEW_VALUES = {
      "show_all_courses" => "two_one",
      "two_two" => "two_two",
      "third_class" => "third_class",
      "not_required" => "pass",
    }.freeze
    private_constant :DEGREE_REQUIRED_OLD_VALUES_TO_NEW_VALUES

    def degree_required_transformation
      DEGREE_REQUIRED_OLD_VALUES_TO_NEW_VALUES[degree_required]
    end

    SORT_BY_OLD_VALUES_TO_NEW_VALUES = {
      "course_asc" => "course_name_ascending",
      "course_desc" => "course_name_descending",
      "provider_asc" => "provider_name_ascending",
      "provider_desc" => "provider_name_descending",
    }.freeze
    private_constant :SORT_BY_OLD_VALUES_TO_NEW_VALUES

    def sort_by_transformation
      SORT_BY_OLD_VALUES_TO_NEW_VALUES[sortby]
    end

    OLD_QUALIFICATION_VALUES_TO_NEW_VALUES = {
      "pgce_with_qts" => "qts_with_pgce_or_pgde",
    }.freeze
    private_constant :OLD_QUALIFICATION_VALUES_TO_NEW_VALUES

    def old_qualification_transformation
      Array(qualification)
        .reject { |old_qualification_param| old_qualification_param == "pgce pgde" }
        .map do |old_qualification_param|
          OLD_QUALIFICATION_VALUES_TO_NEW_VALUES[old_qualification_param] || old_qualification_param
        end
    end

    def university_degree_status_transformation
      return if university_degree_status.nil?

      "no_degree_required" unless university_degree_status
    end

    def old_further_education_parameters?
      age_group == "further_education" ||
        qualification&.include?("pgce pgde")
    end

    def old_provider_name_parameter
      send(:'provider.provider_name')
    end

    def old_parameters
      %i[
        age_group
        degree_required
        lq
        provider.provider_name
        qualification
        sortby
        study_type
        university_degree_status
      ]
    end
  end
end
