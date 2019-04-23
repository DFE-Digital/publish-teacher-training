summary 'Opt-in the provider'
usage 'optin <provider_code1 [provider_code2 ...]>'

run do |opts, args, _cmd|
  MCB.init_rails(opts)

  Provider.connection.transaction do
    args.each do |provider_code|
      provider = Provider.find_by!(provider_code: provider_code)
      verbose "updating provider #{provider_code}"
      provider.update(opted_in: true)

      provider.courses.each do |course|
        next unless course.new?

        enrichment = course.enrichments.latest_first.first
        next unless enrichment.published?

        puts "resetting enrichment #{enrichment.id} for course #{course.course_code} to draft"
        enrichment.update(status: :draft)
      end

      provider.courses.each do |c|
        verbose "  updating course #{c.course_code}"
        c.touch(:changed_at)
      end
    end
  end
end
