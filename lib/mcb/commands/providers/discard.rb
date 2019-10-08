summary "Discards a provider"
usage "discard <provider code>"
param :code, transform: ->(code) { code.upcase }

run do |opts, args, _cmd|
  MCB.init_rails(opts)
  provider = MCB.get_recruitment_cycle(opts).providers.find_by!(provider_code: args[:code])
  provider.discard
end
