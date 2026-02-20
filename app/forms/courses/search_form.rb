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

    # Location category tracking #
    attribute :previous_location_category

    attr_accessor :providers_cache, :subjects_cache

    delegate :primary_subjects, :primary_subject_codes, :secondary_subjects, :secondary_subject_codes, :all_subjects, to: :subjects_cache
    delegate :providers_list, to: :providers_cache

    MINIMUM_DEGREE_REQUIRED_OPTIONS = %w[two_one two_two third_class pass no_degree_required].freeze
    FUNDING_OPTIONS = %w[fee salary apprenticeship].freeze
    QUALIFICATION_OPTIONS = %w[qts qts_with_pgce_or_pgde].freeze
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
        .then { |params| inject_defaults(params) }
        .compact_blank
    end

    # A single checkbox arrives as a string instead of an array
    # return nil if empty
    def funding
      Array(super).presence
    end

    def order
      OrderingStrategy.new(
        location:,
        funding: funding,
        current_order: location_category_changed? ? nil : super,
      ).call
    end

    def minimum_degree_required
      super.presence || self.minimum_degree_required = "show_all_courses"
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
    LONDON_RADIUS = 20

    def self.radius_values
      [10, 20, 50, 100].freeze
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
      START_DATE_OPTIONS
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

    def inject_defaults(params)
      params.tap do
        params[:radius] = (radius if location.present?)
        params[:level] = level
        params[:minimum_degree_required] = minimum_degree_required
        params[:order] = order
        params[:provider_name] = provider_name
        params[:study_types] = study_types
        params[:qualifications] = qualifications

        params[:engineers_teach_physics] = nil unless search_for_physics?
      end
    end
  end
end
