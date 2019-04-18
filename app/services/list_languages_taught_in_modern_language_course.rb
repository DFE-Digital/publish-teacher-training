class ListLanguagesTaughtInModernLanguageCourse
  LANGUAGE_SUBJECTS = [
    'English as a foreign language',
    'French',
    'German',
    'Italian',
    'Japanese',
    'Mandarin',
    'Russian',
    'Spanish',
    'Urdu'
  ].freeze

  attr_reader :course, :ucas_subject_names

  def self.call(course, ucas_subject_names)
    new(course, ucas_subject_names).call
  end

  def initialize(course, ucas_subject_names)
    @course             = course
    @ucas_subject_names = ucas_subject_names
  end

  def call
    return [] unless course.secondary?

    dfe_subject_names.select do |subject_name|
      subject_name.in? LANGUAGE_SUBJECTS
    end
  end

private

  def dfe_subject_names
    SubjectMapper.get_subject_list(
      course.name,
      ucas_subject_names
    )
  end
end
