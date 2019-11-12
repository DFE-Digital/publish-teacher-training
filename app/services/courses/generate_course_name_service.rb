module Courses
  class GenerateCourseNameService
    def execute(course:)
      subjects = course.subjects

      title = if course.further_education_course?
                further_education_title
              elsif is_modern_lanuage_course?(subjects)
                modern_language_title(subjects)
              else
                generated_title(subjects)
              end

      title += " (SEND)" if course.is_send?
      title
    end

  private

    def is_modern_lanuage_course?(subjects)
      subjects.any? { |s| s == SecondarySubject.modern_languages }
    end

    def modern_language_title(subjects)
      title = SecondarySubject.modern_languages.to_s

      languages = subjects.select { |s| s.type == "ModernLanguagesSubject" }
      languages = languages.reject { |language| language.subject_name.casecmp?("Modern languages (other)") }

      return title if languages.empty? || languages.length >= 4

      language_names = languages.map { |language| format_language_name(language) }

      if language_names.length == 1
        title + " (#{language_names[0]})"
      elsif language_names.length == 2
        title + " (#{language_names.join(' and ')})"
      elsif language_names.length == 3
        title + " (#{language_names.join(', ')})"
      end
    end

    def generated_title(subjects)
      return "" if subjects.empty?

      subjects = subjects.map { |s| format_subject_name(s) }

      if subjects.length == 1
        subjects[0]
      else
        "#{subjects[0]} with #{subjects[1]}"
      end
    end

    def further_education_title
      "Further education"
    end

    def format_subject_name(subject)
      if subject.subject_name.casecmp?("Communication and media studies")
        "Media studies"
      else
        subject.to_s
      end
    end

    def format_language_name(language)
      if language.subject_name.casecmp?("English as a second or other language")
        "English"
      else
        language.to_s
      end
    end
  end
end
