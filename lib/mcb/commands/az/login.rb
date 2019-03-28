name 'login'
summary 'run az login'

run do |_opts, args, _cmd|
  system('az login')
end
