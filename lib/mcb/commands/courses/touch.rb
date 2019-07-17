summary 'Update a course so that it will be at the top of the apiv1 results'
usage 'touch <provider_code> <course_code>'
param :provider_code
param :course_code

run do |opts, args, _cmd|
  MCB.init_rails(opts)

  provider = MCB.get_recruitment_cycle(opts).providers.find_by!(provider_code: args[:provider_code].upcase)
  course = provider.courses.find_by!(course_code: args[:course_code].upcase)
  course.touch
  course.update! audit_comment: 'timestamps updated to expose in api v1'
end
