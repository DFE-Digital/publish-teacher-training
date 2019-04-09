summary 'Retrieve and display the token from the given env'

run do |opts, _args, _cmd|
  MCB.init_rails unless opts.key? :webapp
  puts MCB.apiv1_token(opts.slice(:webapp, :rgroup))
end
