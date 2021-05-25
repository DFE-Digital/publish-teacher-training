summary "Create a copy of provider's courses for the next recruitment cycle"

run do |opts, args, _cmd|
  MCB.init_rails(opts)
  RolloverService.call(provider_codes: args)
end
