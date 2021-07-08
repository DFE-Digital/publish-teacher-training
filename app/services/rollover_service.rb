class RolloverService
  include ServicePattern

  def initialize(provider_codes:, force: false)
    @provider_codes = provider_codes
    @force = force
  end

  def call
    total_counts = { providers: 0, sites: 0, courses: 0 }

    total_bm = Benchmark.measure do
      providers.each { |provider| rollover(provider, total_counts) }
    end

    puts "Rollover done: " \
         "#{total_counts[:providers]} providers, " \
         "#{total_counts[:sites]} sites, " \
         "#{total_counts[:courses]} courses " \
         "in %.3f seconds" % total_bm.real
  end

private

  attr_reader :provider_codes, :force

  def rollover(provider, total_counts)
    print "Copying provider #{provider.provider_code}: "
    counts = nil

    bm = Benchmark.measure do
      Provider.connection.transaction do
        copy_courses_to_provider_service = Courses::CopyToProviderService.new(
          sites_copy_to_course: Sites::CopyToCourseService.new,
          enrichments_copy_to_course: Enrichments::CopyToCourseService.new,
        )

        copy_provider_to_recruitment_cycle = Providers::CopyToRecruitmentCycleService.new(
          copy_course_to_provider_service: copy_courses_to_provider_service,
          copy_site_to_provider_service: Sites::CopyToProviderService.new,
          logger: Logger.new(STDOUT),
          force: force,
        )

        counts = copy_provider_to_recruitment_cycle.execute(
          provider: provider, new_recruitment_cycle: new_recruitment_cycle,
        )
      end
    end

    puts "provider #{counts[:providers].zero? ? 'skipped' : 'copied'}, " \
         "#{counts[:sites]} sites copied, " \
         "#{counts[:courses]} courses copied " \
         "in %.3f seconds" % bm.real

    total_counts.merge!(counts) { |_, total, count| total + count }
  end

  def new_recruitment_cycle
    @new_recruitment_cycle ||= RecruitmentCycle.next_recruitment_cycle
  end

  def providers
    @providers ||= if provider_codes.any?
                     RecruitmentCycle.current_recruitment_cycle
                                     .providers.where(provider_code: provider_codes.to_a.map(&:upcase))
                   else
                     RecruitmentCycle.current_recruitment_cycle.providers
                   end
  end
end
