# rubocop:disable Style/ClassVars
class TestSetup
  # A helper class for instantiating a standard set of factories for testing
  #
  # There are two ways to access the data. Via class methods or class instantiation.
  #
  # This class automatically generates a set of test data and can be accessed as follows:
  #
  # e.g. TestSetup.unpublished_with_primary_maths
  #
  # Use the above method when you do not need to customise the test data.
  #
  # If you do need to custom aspects of the test data then define a 'before(:all)' block in your spec
  # and instantiate the TestSetup class, passing in the attributes you require:
  #
  # e.g @setup = TestSetup.new(with_courses: [
  #   :unpub_pri_math: { created_date: 2.days.ago }
  # ])
  #
  # [DRAFT] The naming schema for courses is:
  #
  #   <publish state>_<level>_<subject>_<other_info>
  #
  # where:
  #
  # * publish_state:
  #
  #   * pub = published
  #   * unpub = unpublished
  #   * del = deleted
  #
  # * level:
  #
  #   * pri - primary
  #   * sec - secondary
  #
  # * subject:
  #   * mat - maths
  #   * eng - eng

  @@recruitment_cycles = {
    current_cycle: -> {  find_or_create :recruitment_cycle },
    next_cycle: -> {  find_or_create :recruitment_cycle, :next },
  }

  @@courses = {
    unpub_pri_math: ->(attributes = {}) do
      find_or_create(:course, :unpublished_with_primary_maths, attributes)
    end,
  }

  def self.method_missing(method_name, *args)
    if @@recruitment_cycles&.key?(method_name)
      @@recruitment_cycles[method_name].call
    elsif @@courses&.key?(method_name)
      @@courses[method_name].call
    elsif %i[build find_or_create].include? method_name
      FactoryBot.send(method_name, *args)
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
      create_custom_courses_from(with_courses)
    else
      create_courses_from(with_courses)
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

private

  def create_courses_from(courses)
    course_types = courses || @@courses.keys
    @courses = Hash[
        @@courses.slice(*course_types).map do |name, kourse|
          # instantiate course by calling the blocks in @@courses
          [name, kourse.call]
        end
    ]
  end

  def create_custom_courses_from(courses)
    @courses = @@courses.slice(*courses.keys)
    courses.each do |name, attrs|
      # instantiate course by calling the blocks in @@courses and passing in any
      # attributes defined in only_courses for this course.
      @courses[name] = @courses[name].call(attrs)
    end
  end
end
# rubocop:enable Style/ClassVars
