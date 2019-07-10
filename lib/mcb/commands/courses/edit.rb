name 'edit'
summary 'Edit one or more courses directly in the DB'
usage 'edit <provider_code> <course code 1> [<course code 2> ...]'

run do |opts, args, _cmd|
  MCB.init_rails(opts)

  provider_code = args[0].upcase
  course_codes = args.to_a[1..-1].map(&:upcase)

  MCB::CoursesEditor.new(
    requester: User.find_by!(email: MCB.config[:email]),
    provider: RecruitmentCycle.current_recruitment_cycle.providers.find_by!(provider_code: provider_code),
    course_codes: course_codes
  ).run
end
