class ListLanguagesTaughtInModernLanguageCourse
  LANGUAGES = [
    'english as a foreign language',
    'french',
    'german',
    'italian',
    'japanese',
    'mandarin',
    'russian',
    'spanish',
    'urdu'
  ].freeze

  MODERN_LANGUAGE_COURSE_PATTERN = /mfl|modern language|modern foreign language/.freeze

  attr_reader :course_name, :ucas_subject_names

  def self.call(course_name, ucas_subject_names)
    new(course_name, ucas_subject_names).call
  end

  def initialize(course_name, ucas_subject_names)
    @course_name        = course_name
    @ucas_subject_names = ucas_subject_names
  end

  def call
    return [] unless modern_language_course?

    LANGUAGES.select do |language|
      language.in? normalized_ucas_subject_names
    end
  end

private

  def normalized_ucas_subject_names
    @normalized_ucas_subject_names ||= ucas_subject_names.strip.downcase
  end

  def modern_language_course?
    course_name.downcase.match?(MODERN_LANGUAGE_COURSE_PATTERN)
  end
end
