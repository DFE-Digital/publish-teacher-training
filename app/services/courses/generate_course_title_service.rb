module Courses
  class GenerateCourseTitleService
    def execute(course:)
      subjects = course.subjects

      title = if course.further_education_course?
                further_education_title
              elsif is_modern_lanuage_course?(subjects)
                modern_language_title(subjects)
              else
                generated_title(subjects)
              end

      title = append_send_info(title) if course.is_send?
      title
    end

  private

    def is_modern_lanuage_course?(subjects)
      subjects.any? { |s| s == SecondarySubject.modern_languages }
    end

    def modern_language_title(subjects)
      title = "Modern Languages"

      languages = subjects.select { |s| s.type == "ModernLanguagesSubject" }

      if languages.length == 1
        title += " (#{languages[0]})"
      elsif languages.length == 2
        title += " (#{languages[0]} and #{languages[1]})"
      elsif languages.length == 3
        title += " (#{languages[0]}, #{languages[1]}, #{languages[2]})"
      end

      title
    end

    def generated_title(subjects)
      return "" if subjects.empty?

      if subjects.length == 1
        subjects[0].to_s
      else
        "#{subjects[0]} with #{subjects[1]}"
      end
    end

    def further_education_title
      "Further education"
    end

    def append_send_info(title)
      title + " with Special educational needs and disability"
    end
  end
end
