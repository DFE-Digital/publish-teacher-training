# coding: utf-8

summary 'Show course info from the db'
usage 'show <provider_code> <course_code>'
param :provider_code, transform: ->(code) { code.upcase }
param :course_code, transform: ->(code) { code.upcase }

run do |opts, args, _cmd|
  MCB.init_rails(opts)

  provider = MCB.get_recruitment_cycle(opts).providers.find_by!(provider_code: args[:provider_code])
  course = provider.courses.find_by!(course_code: args[:course_code])

  puts MCB::Render::ActiveRecord.course(course)
end
