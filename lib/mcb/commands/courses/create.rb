name 'create'
summary 'Create a new course in db'
usage 'create <provider_code>'
param :provider_code, transform: ->(code) { code.upcase }

class CourseEditor
  def initialize(cli:, course:)
    @cli = cli
    @course = course
  end

  def new_course_wizard
    ask_name
    ask_course_code
    ask_qualification
    ask_study_mode
    ask_age_range
    ask_accredited_body
    ask_start_date
    ask_program_type
    ask_maths
    ask_english
    ask_science
    ask_ucas_subjects

    if confirm_creation?
      try_saving_course
      ask_sites
      ask_applications_accepted_from
      print_summary
    else
      puts "Aborting"
    end
  end

  def ask_name
    @course.name = @cli.ask("Course name?  ")
  end

  def ask_qualification
    @course.qualification = @cli.choose do |menu|
      menu.prompt = "What's the course outcome? (#{@course.qualification} if blank)  "
      menu.choices(*Course.qualifications.keys)
      menu.default = @course.qualification
    end
  end

  def ask_study_mode
    @course.study_mode = @cli.choose do |menu|
      menu.prompt = "Full time or part time? (#{@course.study_mode} if blank)  "
      menu.choices(*Course.study_modes.keys)
      menu.default = @course.study_mode
    end
  end

  def ask_age_range
    @course.age_range = @cli.choose do |menu|
      menu.prompt = "What's the level of the course?  "
      menu.choices(*Course.age_ranges.keys)
    end
  end

  def ask_accredited_body
    code = @cli.ask("Provider code of accredited body (leave blank if self-accredited)  ")
    @course.accrediting_provider = code.present? ? Provider.find_by(provider_code: code) : @course.provider
  end

  def ask_start_date
    @course.start_date = Date.parse(@cli.ask("Start date?  ") { |q| q.default = @course.start_date.strftime("%b %Y") })
  end

  def ask_course_code
    @course.course_code = @cli.ask("Course code?  ")
  end

  def ask_program_type
    @course.program_type = @cli.choose do |menu|
      menu.prompt = "What's the route?  "
      menu.choices(*Course.program_types.keys)
    end
  end

  [:maths, :english, :science].each do |subject|
    define_method("ask_#{subject}") do
      answer = @cli.choose do |menu|
        menu.prompt = "What's the #{subject} entry requirements?  "
        menu.choices(*Course::ENTRY_REQUIREMENT_OPTIONS.keys)
      end
      @course.send("#{subject}=".to_sym, answer)
    end
  end

  def ask_ucas_subjects
    puts "Original subjects: #{@course.subjects.pluck(:subject_name).join(', ')}"

    finished = false
    cancel = false
    subjects = []
    until finished
      @cli.choose do |menu|
        subject_list = !subjects.empty? ? "(#{subjects.map(&:subject_name).join(', ')} so far)" : ""
        menu.prompt = "UCAS subjects to assign?#{subject_list}  "

        menu.choice("No more subjects") { finished = true }
        menu.choice("Cancel without saving") { finished = true; cancel = true }
        Subject.all.order(:subject_name).each do |subject|
          menu.choice(subject.subject_name) { |cmd| subjects << subject }
        end
      end
    end
    @course.subjects = subjects unless cancel
  end

  def ask_sites
    finished = false
    until finished
      @cli.choose do |menu|
        sites_list = !@course.sites.empty? ? "(#{@course.sites.map(&:location_name).join(', ')} so far)" : ""
        menu.prompt = "Which training locations to assign? #{sites_list}  "

        menu.choice("No more training locations") { finished = true }
        @course.provider.sites.each do |site|
          menu.choice(site.location_name) { |cmd| @course.add_site!(site: site) }
        end
      end
    end
  end

  def ask_applications_accepted_from
    response = @cli.ask("Date that applications accepted from? (#{::SiteStatus.applications_accepted_from_default.strftime("%d %b %Y")} if blank)  ")
    @course.applications_accepted_from = Date.parse(response) unless response.empty?
  end

  def confirm_creation?
    puts "\nAbout to create the following course:"
    print_course
    @cli.agree("Continue? ")
  end

  def print_summary
    puts "\nHere's the final course that's been created:"
    print_course
    @cli.ask("Press Enter to continue")
  end

  def print_course
    puts Terminal::Table.new rows: MCB::CourseShow.new(@course).to_h
  end

  def try_saving_course
    if @course.valid?
      puts "Saving the course"
      @course.save!
    else
      puts "Course isn't valid:"
      @course.errors.full_messages.each { |error| puts " - #{error}" }
    end
  end
end

run do |opts, args, _cmd|
  MCB.init_rails(opts)

  Course.connection.transaction do
    provider = Provider.find_by!(provider_code: args[:provider_code])
    course = provider.courses.build
    CourseEditor.new(cli: HighLine.new, course: course).new_course_wizard
  end
end
