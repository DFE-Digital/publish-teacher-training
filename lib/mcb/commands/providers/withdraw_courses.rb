summary "Withdraw courses for a pre determined list of providers"
usage "withdraw_courses <provider code1> [provider code2] ...""

run do |opts, args, _cmd|
  MCB.init_rails(opts)
  current_cycle = RecruitmentCycle.current
  args.each do |provider_code|
    provider = current_cycle.providers.find_by!(provider_code: provider_code.upcase)
    provider.courses.each(&:withdraw)
  end
end
