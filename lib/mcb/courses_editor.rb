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
      finished = false
      puts "Editing #{course_codes.join(', ')}"
      until finished
        choice = @cli.choose do |menu|
          menu.choice(:exit) { finished = true }
          menu.choice("edit title")
        end

        case choice
        when "edit title"
          edit_title
        end
      end
    end

  private

    def edit_title
      print_existing(:name)
      update(name: ask_title)
    end

    def ask_title
      @cli.ask("New course title?  ")
    end

    def check_authorisation
      @courses.each { |course| raise Pundit::NotAuthorizedError unless can_update?(course) }
    end

    def print_existing(attribute_name)
      puts "Existing values for course #{attribute_name}:"
      table = Tabulo::Table.new @courses.order(:course_code) do |t|
        t.add_column(:course_code, header: "course\ncode", width: 4)
        t.add_column(attribute_name)
      end
      puts table.pack(max_table_width: nil), table.horizontal_rule
    end

    def update(attrs)
      @courses.each { |course| course.update(attrs) }
    end

    def can_update?(course)
      CoursePolicy.new(@requester, course).update?
    end

    def course_codes
      @courses.order(:course_code).pluck(:course_code)
    end

    def find_courses(course_codes)
      courses = Course.where(course_code: course_codes)
      missing_course_codes = course_codes - courses.pluck(:course_code)
      raise ArgumentError, "Couldn't find course " + missing_course_codes.join(", ") unless missing_course_codes.empty?

      courses
    end
  end
end
