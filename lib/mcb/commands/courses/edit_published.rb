name 'edit_published'
summary 'Edit publisheds course directly in the DB'

ENTRY_REQUIREMENT_OPTIONS = {
  must_have_qualification_at_application_time: 1,
  expect_to_achieve_before_training_begins: 2,
  equivalence_test: 3,
  not_required: 9,
  not_set: nil,
}.freeze

def vacancy_status(course)
  case course.study_mode
  when "full_time"
    :full_time_vacancies
  when "part_time"
    :part_time_vacancies
  when "full_time_or_part_time"
    :both_full_time_and_part_time_vacancies
  else
    raise "Unexpected study mode #{course.study_mode}"
  end
end

def site_choices(course, provider)
  existing_sites = course.site_statuses.map(&:site)
  new_sites_to_add = provider.sites - existing_sites
  site_status_choices = course.site_statuses.map {|ss| "#{ss.site.location_name} (code: #{ss.site.code}) – #{ss.status}/#{ss.publish}" }
  new_site_choices = new_sites_to_add.map {|s| "#{s.location_name} (code: #{s.code})" }

  site_status_choices + new_site_choices
end

def toggle_site(course, site_str)
  site_code = site_str.match(/\(code: (.*)\)/)[1]
  if site_status = course.site_statuses.detect { |ss| ss.site.code == site_code }
    puts "Toggling #{site_status}"
    site_status.toggle!
  else
    is_course_new = course.new? # persist this before we create the site status
    site_status = SiteStatus.create!(
      course: course,
      site: new_sites_to_add.detect { |s| s.code == site_code },
      vac_status: vacancy_status(course),
      status: :new_status,
      applications_accepted_from: Date.today,
      publish: :unpublished,
    )
    site_status.start! unless is_course_new
  end
end

run do |opts, args, _cmd|
  MCB.init_rails(opts)

  cli = HighLine.new

  provider_code = cli.ask("Provider code?  ")
  provider = Provider.find_by!(provider_code: provider_code)

  course_code = cli.ask("Course code?  ")
  course = provider.courses.find_by!(course_code: course_code)

  flow = :root
  loop do
    cli.choose do |menu|
      case flow
      when :root
        puts Terminal::Table.new rows: MCB::CourseShow.new(course).to_h
        puts "Course status: #{course.ucas_status}"

        menu.prompt = "Editing course"
        menu.choice(:exit) { exit }
        menu.choice(:toggle_sites) { flow = :toggle_sites }
        menu.choice(:edit_route) { flow = :edit_route }
        menu.choice(:edit_qualifications) { flow = :edit_qualifications }
        menu.choice(:edit_english) { flow = :edit_english }
        menu.choice(:edit_maths) { flow = :edit_maths }
        menu.choice(:edit_science) { flow = :edit_science }
      when :toggle_sites
        menu.prompt = "Toggling course sites"
        menu.choice(:done) { flow = :root }
        menu.choices(*(site_choices(course, provider))) do |site_str|
          toggle_site(course, site_str)
        end
      when :edit_route
        menu.prompt = "Editing course route"
        menu.choice(:done) { flow = :root }
        menu.choices(*Course.program_types.keys) do |value|
          course.program_type = value
          course.save!
          flow = :root
        end
      when :edit_qualifications
        menu.prompt = "Editing course qualifications"
        menu.choice(:done) { flow = :root }
        menu.choices(*Course.qualifications.keys) do |value|
          course.qualification = value
          course.save!
          flow = :root
        end
      when :edit_english
        menu.prompt = "Editing course english"
        menu.choice(:done) { flow = :root }
        menu.choices(*ENTRY_REQUIREMENT_OPTIONS.keys) do |value|
          course.english = value
          course.save!
          flow = :root
        end
      when :edit_maths
        menu.prompt = "Editing course maths"
        menu.choice(:done) { flow = :root }
        menu.choices(*ENTRY_REQUIREMENT_OPTIONS.keys) do |value|
          course.maths = value
          course.save!
          flow = :root
        end
      when :edit_science
        menu.prompt = "Editing course science"
        menu.choice(:done) { flow = :root }
        menu.choices(*ENTRY_REQUIREMENT_OPTIONS.keys) do |value|
          course.science = value
          course.save!
          flow = :root
        end
      end
    end
    course.reload
    course.site_statuses.reload
  end
end
