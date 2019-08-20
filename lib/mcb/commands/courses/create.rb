summary 'Create a new course in db'
usage 'create <provider_code>'
param :provider_code, transform: ->(code) { code.upcase }

run do |opts, args, _cmd|
  MCB.init_rails(opts)

  Course.connection.transaction do
    provider = MCB.get_recruitment_cycle(opts).providers.find_by!(provider_code: args[:provider_code])
    requester = User.find_by!(email: MCB.config[:email])

    MCB::Editor::CoursesEditor.new(
      provider: provider,
      requester: requester,
      courses: [provider.courses.build]
    ).new_course_wizard
  end
end
