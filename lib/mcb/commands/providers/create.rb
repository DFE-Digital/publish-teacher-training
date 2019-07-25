summary 'Create a new provider'
#param :provider, transform: ->(code) { code.upcase }

run do |_opts, _args, _cmd|
  MCB::ProviderEditor.new(provider: nil, requester: nil)
end
