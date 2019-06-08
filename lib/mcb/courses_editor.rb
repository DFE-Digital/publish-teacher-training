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
      print_at_most_two_courses
      until finished
        choice = @cli.choose do |menu|
          menu.choice(:exit) { finished = true }
          menu.choices(
            "edit title",
            "edit maths",
            "edit english",
            "edit science",
            "edit route",
            "edit qualifications",
            "edit study mode",
            "edit accredited body",
            "edit start date",
            "edit application opening date",
          )
        end

        if choice.is_a?(String) && choice.start_with?("edit")
          edit_method_name = choice.gsub(" ", "_").to_sym
          send(edit_method_name)
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

    def edit_maths
      print_existing(:maths)
      update(maths: ask_gcse_subject(:maths))
    end

    def edit_english
      print_existing(:english)
      update(english: ask_gcse_subject(:english))
    end

    def edit_science
      print_existing(:science)
      update(science: ask_gcse_subject(:science))
    end

    def ask_gcse_subject(subject)
      @cli.choose do |menu|
        menu.prompt = "What's the #{subject} entry requirements?  "
        menu.choices(*Course::ENTRY_REQUIREMENT_OPTIONS.keys)
      end
    end

    def edit_route
      print_existing(:program_type)
      update(program_type: ask_route)
    end

    def ask_route
      @cli.choose do |menu|
        menu.prompt = "What's the route?  "
        menu.choices(*Course.program_types.keys)
      end
    end

    def edit_qualifications
      print_existing(:qualification)
      update(qualification: ask_qualifications)
    end

    def ask_qualifications
      @cli.choose do |menu|
        menu.prompt = "What's the course outcome?  "
        menu.choices(*Course.qualifications.keys)
        menu.default = "pgce_with_qts"
      end
    end

    def edit_study_mode
      print_existing(:study_mode)
      update(study_mode: ask_study_mode)
    end

    def ask_study_mode
      @cli.choose do |menu|
        menu.prompt = "Full time or part time?  "
        menu.choices(*Course.study_modes.keys)
        menu.default = "full_time"
      end
    end

    def edit_accredited_body
      print_existing(:accrediting_provider)
      update(accrediting_provider: ask_accredited_body)
    end

    def ask_accredited_body
      new_accredited_body = nil
      until new_accredited_body.present?
        begin
          new_accredited_body = ask_accredited_body_once
        rescue ActiveRecord::RecordNotFound
          puts "Can't find accredited body; please enter one that exists."
        end
      end
      new_accredited_body
    end

    def ask_accredited_body_once
      code = @cli.ask "Provider code of accredited body (leave blank if self-accredited)  ", ->(str) { str.upcase }
      code.present? ? Provider.find_by!(provider_code: code) : @provider
    end

    def edit_start_date
      print_existing(:start_date)
      update(start_date: ask_start_date)
    end

    def ask_start_date
      Date.parse(@cli.ask("Start date?  ") { |q| q.default = "September #{@courses.first.recruitment_cycle}" })
    end

    def edit_application_opening_date
      print_existing(:applications_open_from)
      update(applications_open_from: ask_application_opening_date)
    end

    def ask_application_opening_date
      Date.parse(@cli.ask("Applications opening date?  ") { |q| q.default = Date.today.to_s })
    end

    def check_authorisation
      @courses.each { |course| raise Pundit::NotAuthorizedError unless can_update?(course) }
    end

    def print_at_most_two_courses
      @courses.take(2).each { |course| puts MCB::Render::ActiveRecord.course(course) }
      puts "Only showing first 2 courses" if @courses.size > 2
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
