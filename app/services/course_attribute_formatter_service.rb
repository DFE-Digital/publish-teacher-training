class CourseAttributeFormatterService
  def initialize(name:, value:)
    @name = name
    @value = value
  end

  class << self
    def call(**args)
      new(args).call
    end
  end

  def call
    return age_range_value if age_range?
    return qualification_value if qualification?
    return study_mode_value if study_mode?
    return entry_requirements_value if entry_requirements?

    value
  end

  private_class_method :new

private

  attr_reader :name, :value

  def age_range?
    name == "age_range_in_years"
  end

  def age_range_value
    strip_underscores
  end

  def qualification?
    name == "qualification"
  end

  def qualification_value
    I18n.t("course.values.qualification.#{value}")
  end

  def study_mode?
    name == "study_mode"
  end

  def study_mode_value
    strip_underscores
  end

  def entry_requirements?
    %w(maths english science).include?(name)
  end

  def entry_requirements_value
    strip_underscores
  end

  def strip_underscores
    value.tr("_", " ")
  end
end
