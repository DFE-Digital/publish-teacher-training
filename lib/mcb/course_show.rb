module MCB
  class CourseShow
    def initialize(course)
      @course = course
    end

    def to_h
      {
        "Course code" => @course.course_code,
        "Description" => @course.description,
        "Provider" => @course.provider.provider_code,
        "Accredited body" => @course.accrediting_provider&.provider_code || "Self-accrediting",
        "Subjects" => @course.dfe_subjects.join(", "),
        "Level" => @course.level,
        "Training locations" => @course.site_statuses.map(&:site).map(&:location_name).join(", "),
        "Start date" => @course.start_date.strftime("%b %Y"),
        "Route" => @course.program_type,
        "Age range" => @course.age_range,
        "Modular" => @course.modular,
        "English" => @course.english,
        "Maths" => @course.maths,
        "Science" => @course.science,
      }
    end
  end
end
