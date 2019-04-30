name 'create'
summary 'Create a new course in db'
usage 'create <provider_code>'
param :provider_code

class NewCourseWizardCLI
  attr_reader :course

  def initialize(cli, wizard)
    @cli = cli
    @ucas_subjects = []
    @sites = []

    @wizard = wizard
  end

  def course
    @wizard.course
  end

  def run
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
    ask_sites
    ask_applications_accepted_from
  end

  def ask_name
    @wizard.name = @cli.ask("Course name?  ")
  end

  def ask_qualification
    @wizard.qualification = @cli.choose do |menu|
      menu.prompt = "What's the course outcome? (#{@wizard.qualification_default} if blank)  "
      menu.choices(*@wizard.qualification_options, &:to_sym)
      menu.default = @wizard.qualification_default
    end
  end

  def ask_study_mode
    @wizard.study_mode = @cli.choose do |menu|
      menu.prompt = "Full time or part time? (#{@wizard.study_mode_default} if blank)  "
      menu.choices(*@wizard.study_mode_options, &:to_sym)
      menu.default = @wizard.study_mode_default
    end
  end

  def ask_age_range
    @wizard.age_range = @cli.choose do |menu|
      menu.prompt = "What's the level of the course?  "
      menu.choices(*@wizard.age_range_options, &:to_sym)
    end
  end

  def ask_accredited_body
    @wizard.accredited_body_provider_code = @cli.ask("Provider code of accredited body (leave blank if self-accredited)  ")
  end

  def ask_start_date
    @wizard.start_date = Date.parse(@cli.ask("Start date?  ") { |q| q.default = @wizard.start_date_default.strftime("%b %Y") })
  end

  def ask_course_code
    @wizard.course_code = @cli.ask("Course code?  ")
  end

  def ask_program_type
    @wizard.program_type = @cli.choose do |menu|
      menu.prompt = "What's the route?  "
      menu.choices(*@wizard.program_type_options, &:to_sym)
    end
  end

  [:maths, :english, :science].each do |subject|
    define_method("ask_#{subject}") do
      answer = @cli.choose do |menu|
        menu.prompt = "What's the #{subject} entry requirements?  "
        menu.choices(*@wizard.entry_requirement_options, &:to_sym)
      end
      @wizard.send("#{subject}=".to_sym, answer)
    end
  end

  def ask_ucas_subjects
    finished = false
    subjects = []
    until finished
      @cli.choose do |menu|
        subject_list = !subjects.empty? ? "(#{subjects.map(&:subject_name).join(', ')} so far)" : ""
        menu.prompt = "UCAS subjects to assign?#{subject_list}  "

        subject_choices = @wizard.ucas_subject_options.order(:subject_name).pluck(:subject_name)
        menu.choices(*(subject_choices + ['no more subjects'])) do |cmd|
          cmd == 'no more subjects' ? finished = true : subjects << @wizard.ucas_subject_options.detect { |s| s.subject_name == cmd }
        end
      end
    end
    @wizard.subjects = subjects
  end

  def ask_sites
    finished = false
    sites = []
    until finished
      @cli.choose do |menu|
        sites_list = !sites.empty? ? "(#{sites.map(&:location_name).join(', ')} so far)" : ""
        menu.prompt = "Which training locations to assign?#{sites_list}  "

        site_choices = @wizard.site_options.order(:location_name).pluck(:location_name)
        menu.choices(*(site_choices + ['no more training locations'])) do |cmd|
          if cmd == 'no more training locations'
            finished = true
          else
            sites << @wizard.site_options.detect { |s| s.location_name == cmd }
          end
        end
      end
    end
    @wizard.sites = sites
  end

  def ask_applications_accepted_from
    @wizard.applications_accepted_from = Date.parse(@cli.ask("Date that applications accepted from?  ") { |q| q.default = @wizard.applications_accepted_from_default.strftime("%d %b %Y") })
  end
end

def confirm_creation_of(course)
  puts "\nAbout to create the following course:"
  puts Terminal::Table.new rows: MCB::CourseShow.new(course).to_h

  print "Continue? "

  response = $stdin.readline
  response.match %r{^y(es?)?}i
end

run do |opts, args, _cmd|
  MCB.init_rails(opts)

  Provider.connection.transaction do
    args.each do |provider_code|
      provider = Provider.find_by!(provider_code: provider_code)
      wizard = NewCourseWizard.new(
        provider: provider,
        possible_ucas_subjects: Subject.all,
        possible_sites: Site.where(provider: provider)
      )
      wizard_cli = NewCourseWizardCLI.new(HighLine.new, wizard)
      wizard_cli.run

      course = wizard_cli.course

      if confirm_creation_of(course)
        if wizard.valid?
          puts "Saving the course"
          wizard.save!
        else
          puts "Course isn't valid:"
          wizard.full_error_messages.each { |error| puts " - #{error}" }
        end
      else
        puts "Aborting"
      end
    end
  end
end
