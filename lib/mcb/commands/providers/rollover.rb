summary "Create a copy of provider's courses for the next recruitment cycle"

run do |opts, args, _cmd|
  MCB.init_rails(opts)

  providers = if args.any?
                RecruitmentCycle.current_recruitment_cycle
                  .providers.where(provider_code: args.to_a.map(&:upcase))
              else
                RecruitmentCycle.current_recruitment_cycle.providers
              end

  new_recruitment_cycle = RecruitmentCycle.next_recruitment_cycle
  providers.each do |provider|
    verbose "Rolling-over provider: #{provider.provider_code}"
    provider.copy_to_recruitment_cycle(new_recruitment_cycle)
  end
end
