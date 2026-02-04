# frozen_string_literal: true

module Courses
  class SearchForm < ApplicationForm
    # Search parameters #
    attribute :applications_open, :boolean
    attribute :can_sponsor_visa, :boolean
    attribute :engineers_teach_physics
    attribute :funding
    attribute :interview_location
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
    attribute :excluded_courses

    # Coordinates #
    attribute :country
    attribute :formatted_address
    attribute :postal_code
    attribute :postal_town
    attribute :route
    attribute :locality
    attribute :administrative_area_level_1
    attribute :administrative_area_level_2
    attribute :administrative_area_level_4
    attribute :address_types
    attribute :short_address

    # Old parameters #
    attribute :age_group
    attribute :degree_required
    attribute :lq
    attribute :'provider.provider_name'
    attribute :qualification
    attribute :sortby
    attribute :study_type
    attribute :university_degree_status, :boolean

    # Location category tracking #
    attribute :previous_location_category

    attr_accessor :providers_cache, :subjects_cache

    delegate :primary_subjects, :primary_subject_codes, :secondary_subjects, :secondary_subject_codes, :all_subjects, to: :subjects_cache
    delegate :providers_list, to: :providers_cache

    MINIMUM_DEGREE_REQUIRED_OPTIONS = %w[two_one two_two third_class pass no_degree_required].freeze
    FUNDING_OPTIONS = %w[fee salary apprenticeship].freeze
    QUALIFICATION_OPTIONS = %w[qts qts_with_pgce_or_pgde].freeze
    OLD_START_DATE_OPTIONS = %w[september all_other_dates].freeze
    START_DATE_OPTIONS = %w[jan_to_aug september oct_to_jul].freeze
    STUDY_TYPE_OPTIONS = %w[full_time part_time].freeze

    def initialize(attributes = {})
      super

      @subjects_cache = SubjectsCache.new
      @providers_cache = ProvidersCache.new
    end

    def filter_counts
      {
        degree: degree_filter_count,
        funding: funding&.count,
        interview: boolean_filter_count(interview_location),
        level: boolean_filter_count(level),
        ordering: ordering_filter_count,
        primary_subjects: primary_subject_filter_count,
        provider: boolean_filter_count(provider_code || provider_name),
        qualifications: qualifications&.count,
        radius: radius_filter_count,
        secondary_subjects: secondary_subject_filter_count,
        send_courses: boolean_filter_count(send_courses),
        sponsor_visa: boolean_filter_count(can_sponsor_visa),
        start_date: start_date&.count,
        study_types: study_types&.count,
        teach_physics: boolean_filter_count(engineers_teach_physics),
      }
    end

    def excluded_courses=(attributes)
      super(attributes.is_a?(Hash) ? attributes.values : attributes)
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
      OrderingStrategy.new(
        location:,
        funding: funding,
        current_order: location_category_changed? ? nil : super,
        sortby:,
        find_filtering_and_sorting: FeatureFlag.active?(:find_filtering_and_sorting),
      ).call
    end

    def minimum_degree_required
      if FeatureFlag.active?(:find_filtering_and_sorting) && super.nil?
        return self.minimum_degree_required = "show_all_courses"
      end

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
    DEFAULT_RADIUS = 50
    SMALL_RADIUS = 10
    LONDON_RADIUS = proc { FeatureFlag.active?(:find_filtering_and_sorting) ? 20 : 15 }

    def self.radius_values
      FeatureFlag.active?(:find_filtering_and_sorting) ? [10, 20, 50, 100].freeze : [1, 5, 10, 15, 20, 25, 50, 100, 200].freeze
    end

    def radius_options
      self.class.radius_values.map do |value|
        RadiusOption.new(
          value: value.to_i,
          name: I18n.t("helpers.label.courses_search_form.radius_options.miles", count: value),
        )
      end
    end

    def radius
      return default_radius.call if location_category_changed?

      radius_value = super

      return radius_value if radius_value.present? && radius_value.to_i.in?(self.class.radius_values)

      default_radius.call
    end

    def default_radius
      @default_radius ||= DefaultRadius.new(location:, formatted_address:, address_types:)
    end

    delegate :location_category, to: :default_radius

    def location_category_changed?
      # Only check for category change if previous_location_category was submitted
      # (nil means first visit, "" means form was submitted with no location)
      return false if attributes["previous_location_category"].nil?

      prev = previous_location_category.presence
      current = location_category

      # No change if both are nil/blank (no location before, no location now)
      return false if prev.nil? && current.nil?

      # Changed if different (including nil -> something or something -> nil)
      prev != current
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

    def active_filters
      @active_filters ||= Courses::ActiveFilters::Extractor.new(
        search_form: self,
        search_params: search_params.except(*%i[
          location
          formatted_address
          postal_code
          postal_town
          latitude
          longitude
          country
          route
          locality
          administrative_area_level_1
          administrative_area_level_2
          administrative_area_level_4
          address_types
        ]),
      ).call
    end

    def minimum_degree_required_options
      MINIMUM_DEGREE_REQUIRED_OPTIONS
    end

    def funding_options
      FUNDING_OPTIONS
    end

    def qualification_options
      QUALIFICATION_OPTIONS
    end

    def start_date_options
      FeatureFlag.active?(:find_filtering_and_sorting) ? START_DATE_OPTIONS : OLD_START_DATE_OPTIONS
    end

    def study_type_options
      STUDY_TYPE_OPTIONS
    end

    # When a subject is searched as main subject,
    # the matching subject filter is automatically selected.
    def subjects
      all_subjects = Array(super)

      all_subjects << subject_code unless subject_code.blank? || subject_code.in?(all_subjects)
      all_subjects
    end

  private

    def boolean_filter_count(value)
      value.presence ? 1 : nil
    end

    def primary_subject_filter_count
      return if subjects.blank?

      primary_count = subjects.count { primary_subject_codes.include?(it) }
      primary_count if primary_count.positive?
    end

    def secondary_subject_filter_count
      return if subjects.blank?

      secondary_count = subjects.count { secondary_subject_codes.include?(it) }
      secondary_count if secondary_count.positive?
    end

    def ordering_filter_count
      default_order = location.present? ? "distance" : "course_name_ascending"
      order == default_order ? nil : 1
    end

    def radius_filter_count
      return if location.blank? || attributes["radius"].blank? || radius.to_s == default_radius.call.to_s

      1
    end

    def degree_filter_count
      minimum_degree_required == "show_all_courses" ? nil : 1
    end

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
