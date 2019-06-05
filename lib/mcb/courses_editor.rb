module MCB
  class CoursesEditor
    def initialize(provider:, requester:, course_codes: [])
      @cli = HighLine.new

      @provider = provider
      @requester = requester
      @courses = course_codes.present? ? find_courses(course_codes) : provider.courses

      check_authorisation
    end

    def run
      edit_title
    end

  private

    def edit_title
      update(name: ask_title)
    end

    def ask_title
      @cli.ask("Course title?  ")
    end

    def check_authorisation
      @courses.each { |course| raise Pundit::NotAuthorizedError unless can_update?(course) }
    end

    def update(attrs)
      @courses.each { |course| course.update(attrs) }
    end

    def can_update?(course)
      CoursePolicy.new(@requester, course).update?
    end

    def find_courses(course_codes)
      courses = Course.where(course_code: course_codes)
      missing_course_codes = course_codes - courses.pluck(:course_code)
      raise ArgumentError, "Couldn't find course " + missing_course_codes.join(", ") unless missing_course_codes.empty?

      courses
    end
  end
end
