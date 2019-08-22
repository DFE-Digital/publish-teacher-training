summary "Create a copy of provider's courses for the next recruitment cycle"

run do |opts, args, _cmd| # rubocop:disable Metrics/BlockLength
  MCB.init_rails(opts)

  providers = if args.any?
                RecruitmentCycle.current_recruitment_cycle
                  .providers.where(provider_code: args.to_a.map(&:upcase))
              else
                RecruitmentCycle.current_recruitment_cycle.providers
              end

  new_recruitment_cycle = RecruitmentCycle.next_recruitment_cycle
  total_counts = { providers: 0, sites: 0, courses: 0 }

  total_bm = Benchmark.measure do
    providers.each do |provider|
      print "Copying provider #{provider.provider_code}: "
      counts = nil
      bm = Benchmark.measure do
        Provider.connection.transaction do
          service = Providers::CopyToRecruitmentCycleService.new(provider: provider)
          counts = service.execute(new_recruitment_cycle)
        end
      end
      puts "provider #{counts[:providers] ? 'copied' : 'skipped'}, " \
           "#{counts[:sites]} sites copied, " \
           "#{counts[:courses]} courses copied " \
           'in %.3f seconds' % bm.real
      total_counts.merge!(counts) { |_, total, count| total + count }
    end
  end

  puts "Rollover done: " \
       "#{total_counts[:providers]} providers, " \
       "#{total_counts[:sites]} sites, " \
       "#{total_counts[:courses]} courses " \
       "in %.3f seconds" % total_bm.real
end
