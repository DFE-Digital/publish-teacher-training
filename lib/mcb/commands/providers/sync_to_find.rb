name 'sync_to_find'
summary 'Send all courses for a particular provider to Find'
usage 'sync_to_find <provider_code>'
param :provider_code

run do |opts, args, _cmd|
  MCB.init_rails(opts)

  Provider.connection.transaction do
    provider = Provider.find_by!(provider_code: args[:provider_code])
    user = User.find_by!(email: MCB.config[:email])

    ManageCoursesAPIService::Request.sync_courses_with_search_and_compare(
      MCB.config[:email],
      args[:provider_code]
    )
  end
end
