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
        menu.choices(*(course.actual_and_potential_site_statuses.map(&:description))) do |site_str|
          site_code = site_str.match(/\(code: (.*)\)/)[1]
          course.toggle_site(provider.sites.find_by!(code: site_code))
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
