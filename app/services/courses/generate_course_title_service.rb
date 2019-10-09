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
      subjects[0] == SecondarySubject.modern_languages
    end

    def modern_language_title(subjects)
      title = "Modern Languages"

      if subjects.length == 2
        title += " (#{subjects[1]})"
      elsif subjects.length == 3
        title += " (#{subjects[1]} and #{subjects[2]})"
      elsif subjects.length == 4
        title += " (#{subjects[1]}, #{subjects[2]}, #{subjects[3]})"
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
