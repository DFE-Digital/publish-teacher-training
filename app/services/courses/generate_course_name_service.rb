module Courses
  class GenerateCourseNameService
    def execute(course:)
      subjects = course.subjects
      master_subject = subjects.select { |s| s.id == course.master_subject_id } if course.subjects.present?

      title = if course.further_education_course?
                further_education_title
              elsif course.is_engineers_teach_physics?
                engineers_teach_physics_title(subjects)
              elsif is_modern_lanuage_course?(subjects)
                modern_language_title(subjects)
              else
                generated_title(subjects:, master_subject:)
              end

      title += " (SEND)" if course.is_send?
      title
    end

  private

    def engineers_title
      "Engineers Teach Physics"
    end

    def engineers_teach_physics_title(subjects)
      subject_names = subjects.map { |s| format_subject_name(s) }
      subject_names.delete("Physics")

      if subject_names.blank?
        engineers_title
      else
        "#{engineers_title} with #{subject_names[0]}"
      end
    end

    def is_modern_lanuage_course?(subjects)
      subjects.any? { |s| s == SecondarySubject.modern_languages }
    end

    def modern_language_title(subjects)
      title = SecondarySubject.modern_languages.to_s

      languages = subjects.select { |s| s.type == "ModernLanguagesSubject" }
      languages = languages.reject { |language| language.subject_name.casecmp?("Modern languages (other)") }

      return title if languages.empty? || languages.length >= 4

      language_names = languages.map { |language| format_language_name(language) }

      case language_names.length
      when 1
        title + " (#{language_names[0]})"
      when 2
        title + " (#{language_names.join(' and ')})"
      when 3
        title + " (#{language_names.join(', ')})"
      end
    end

    def generated_title(subjects:, master_subject:)
      return "" if subjects.empty?

      subject_names = subjects.map { |s| format_subject_name(s) }
      master_name = format_subject_name(master_subject)
      subject_names.delete(master_name)

      if subject_names.blank?
        master_name
      else
        "#{master_name} with #{subject_names[0]}"
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
