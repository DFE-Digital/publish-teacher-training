class TestSetup
  # Class that instantiates standard set of test data for specs.

  @@recruitment_cycles = {
    current_cycle: -> { FactoryBot.find_or_create :recruitment_cycle },
    next_cycle: -> { FactoryBot.find_or_create :recruitment_cycle, :next },
  }

  @@courses = {
    unpublished_course_with_primary_maths: ->(attributes = {}) do
      FactoryBot.find_or_create(:course, :unpublished_with_primary_maths, attributes)
    end,
    unpublished_course_with_no_location_or_enrichment: ->(attributes = {}) do
      FactoryBot.find_or_create(:course, :unpublished_with_primary_maths, {
        site_statuses: [],
        enrichments: [],
      }.merge(attributes))
    end,
    unpublished_course_with_draft_enrichment: ->(attributes = {}) do
      FactoryBot.find_or_create(:course, :unpublished_with_primary_maths, attributes)
    end,
    unpublished_fee_type_based_course_with_invalid_enrichment: ->(attributes = {}) do
      FactoryBot.find_or_create(:course, :fee_type_based, :unpublished_with_primary_maths, {
        enrichments: [FactoryBot.build(:course_enrichment, :without_content)],
      }.merge(attributes))
    end,
  }

  # Used when not instantiating a TestSetup object in a before block.
  # This will create a new fixture, using 'find_or_create' for teams and
  # users and 'create' for cases. This is used to have a standardised set of
  # recruitment cycles to work with, but without requiring
  # pre-instantiation.

  def self.method_missing(method_name, *args)
    if @@recruitment_cycles&.key?(method_name)
      @@recruitment_cycles[method_name].call
    elsif @@courses&.key?(method_name)
      @@courses[method_name].call
    else
      super
    end
  end

  def self.respond_to_missing?(method_name, include_private = false)
    @@recruitment_cycles&.key?(method_name) ||
      @@courses&.key?(method_name) ||
      super
  end

  attr_reader :courses, :recruitment_cycles

  def initialize(with_courses: nil)
    @recruitment_cycles = @@recruitment_cycles.transform_values(&:call)
    @courses = @@courses.transform_values(&:call)

    if with_courses.respond_to? :keys
      @courses = @@courses.slice(*with_courses.keys)
      with_courses.each do |name, attrs|
        # instantiate course by calling the blocks in @@courses and passing in any
        # attributes defined in only_courses for this course.
        @courses[name] = @courses[name].call(attrs)
      end
    else
      course_types = with_courses || @@courses.keys
      @courses = Hash[
        @@courses.slice(*course_types).map do |name, kourse|
          # instantiate course by calling the blocks in @@courses
          [name, kourse.call]
        end
      ]
    end
  end

  def method_missing(method_name, *args)
    if @recruitment_cycles&.key?(method_name)
      @recruitment_cycles[method_name]
    elsif @courses&.key?(method_name)
      @courses[method_name]
    else
      super
    end
  end

  def respond_to_missing?(method_name, include_private = false)
    @recruitment_cycles&.key?(method_name) ||
      @courses&.key?(method_name) ||
      super
  end
end
