summary "Discards a provider"
usage "discard provider <provider code>"
param :provider_code, transform: ->(code) { code.upcase }

run do |opts, args, _cmd|
  MCB.init_rails(opts)
  current_cycle = RecruitmentCycle.current
  provider = if opts&.first&.second == current_cycle.year || opts.blank?
               current_cycle.providers.find_by!(provider_code: args[:provider_code])
             else
               RecruitmentCycle.find_by!(year: opts.first.second).providers.find_by!(provider_code: args[:provider_code])
             end
  provider.discard
end
