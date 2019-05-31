name 'sync_to_find'
summary 'Send all courses for a particular provider to Find'
usage 'sync_to_find <provider_code>'
param :provider_code, transform: ->(code) { code.upcase }

run do |opts, args, _cmd|
  MCB.init_rails(opts)

  provider = Provider.find_by!(provider_code: args[:provider_code])
  user = User.find_by!(email: MCB.config[:email])
  unless ProviderPolicy.new(user, provider).show?
    puts "User #{user.email} cannot edit provider #{provider.provider_code}"
    raise CriExitException.new(is_error: true)
  end

  ManageCoursesAPIService::Request.sync_courses_with_search_and_compare(
    user.email,
    provider.provider_code
  )
end
