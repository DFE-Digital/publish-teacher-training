name 'edit_published'
summary 'Edit publisheds course directly in the DB'
param :provider_code
param :course_code

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

def toggle_site(course, provider, site_str)
  existing_sites = course.site_statuses.map(&:site)
  new_sites_to_add = provider.sites - existing_sites
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

  provider = Provider.find_by!(provider_code: args[:provider_code])
  course = provider.courses.find_by!(course_code: args[:course_code])

  flow = :root
  finished = false
  until finished do
    cli.choose do |menu|
      case flow
      when :root
        puts Terminal::Table.new rows: MCB::CourseShow.new(course).to_h
        puts "Course status: #{course.ucas_status}"

        menu.prompt = "Editing course"
        menu.choice(:exit) { finished = true }
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
          toggle_site(course, provider, site_str)
        end
      when :edit_route
        menu.prompt = "Editing course route"
        menu.choices(*Course.program_types.keys) { |value| course.program_type = value }
        flow = :root
      when :edit_qualifications
        menu.prompt = "Editing course qualifications"
        menu.choices(*Course.qualifications.keys) { |value| course.qualification = value }
        flow = :root
      when :edit_english
        menu.prompt = "Editing course english"
        menu.choices(*ENTRY_REQUIREMENT_OPTIONS.keys) { |value| course.english = value }
        flow = :root
      when :edit_maths
        menu.prompt = "Editing course maths"
        menu.choices(*ENTRY_REQUIREMENT_OPTIONS.keys) { |value| course.maths = value }
        flow = :root
      when :edit_science
        menu.prompt = "Editing course science"
        menu.choices(*ENTRY_REQUIREMENT_OPTIONS.keys) { |value| course.science = value }
        flow = :root
      end
    end
    course.save!
    course.reload
    course.site_statuses.reload
  end
end
