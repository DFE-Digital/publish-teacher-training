class RolloverService
  include ServicePattern

  def initialize(provider_codes:, force: false)
    @provider_codes = provider_codes
    @force = force
  end

  def call
    total_counts = { providers: 0, sites: 0, courses: 0 }

    total_bm = Benchmark.measure do
      provider_codes_to_copy.each { |provider_code| rollover(provider_code, total_counts) }
    end

    Rails.logger.info "Rollover done: " \
                      "#{total_counts[:providers]} providers, " \
                      "#{total_counts[:sites]} sites, " \
                      "#{total_counts[:courses]} courses " +
                      format("in %.3f seconds", total_bm.real)
  end

private

  attr_reader :provider_codes, :force

  def rollover(provider_code, total_counts)
    counts = RolloverProviderService.call(provider_code:, force:)

    total_counts.merge!(counts) { |_, total, count| total + count }
  end

  def provider_codes_to_copy
    @provider_codes_to_copy ||= provider_codes.any? ? provider_codes.to_a.map(&:upcase) : RecruitmentCycle.current_recruitment_cycle.providers.pluck(:provider_code)
  end
end
