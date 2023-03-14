# frozen_string_literal: true

module Courses
  class GenerateCourseNameService
    include ServicePattern

    LANGUAGES = %w[
      English
      German
      Italian
      Japanese
      Mandarin
      Russian
      Spanish
      French
      Ancient Greek
      Ancient Hebrew
      Latin
    ].freeze

    ENGINEERS_TEACH_PHYSICS_TITLE = I18n.t('courses.generate_course_name_service.etp_title')
    FURTHER_EDUCATION_TITLE = I18n.t('courses.generate_course_name_service.further_education_title')

    def initialize(course:)
      @course = course
      @subjects = course.course_subjects.sort_by(&:position).map(&:subject)
    end

    def call
      title = if course.further_education_course?
                FURTHER_EDUCATION_TITLE
              else
                generated_title
              end

      title += ' (SEND)' if course.is_send?
      title
    end

    private

    attr_reader :course, :subjects

    def generated_title
      return '' if subjects.empty?

      return formatted_subjects.first if formatted_subjects.length == 1

      "#{formatted_subjects.first} with #{downcase_if_not_language(formatted_subjects.last)}"
    end

    def downcase_if_not_language(subject_name)
      return subject_name if LANGUAGES.any? { |s| subject_name.match s }

      subject_name.downcase
    end

    def formatted_subjects
      modern_language_title = [generate_modern_language_title].compact

      return subjects_excluding_languages.unshift(modern_language_title).flatten if main_subject_is_modern_languages?

      subjects_excluding_languages.concat(modern_language_title)
    end

    def generate_modern_language_title
      return unless course.is_modern_language_course?

      title = SecondarySubject.modern_languages.to_s
      official_languages = languages.reject { |language| language.subject_name.casecmp?('Modern languages (other)') }

      return title if official_languages.empty? || official_languages.length >= 4

      language_names = official_languages.map { |language| format_subject_name(language) }

      case language_names.length
      when 1
        title + " (#{language_names[0]})"
      when 2
        return language_names.join(' and ') unless main_subject_is_modern_languages?

        title + " (#{language_names.join(' and ')})"
      when 3
        title + " (#{language_names.join(', ')})"
      end
    end

    def format_subject_name(subject)
      {
        'communication and media studies' => 'Media studies',
        'physics' => course.is_engineers_teach_physics? ? ENGINEERS_TEACH_PHYSICS_TITLE : subject.to_s
      }[subject.subject_name.downcase] || subject.to_s
    end

    def languages
      @languages ||= subjects.select { |s| s.type == 'ModernLanguagesSubject' }
    end

    def main_subject_is_modern_languages?
      course.master_subject_id == SecondarySubject.modern_languages.id
    end

    def subjects_excluding_languages
      @subjects_excluding_languages ||= (subjects - [SecondarySubject.modern_languages, languages].flatten).map do |s|
        format_subject_name(s)
      end
    end
  end
end
