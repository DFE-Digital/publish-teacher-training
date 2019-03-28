name 'logout'
summary 'run az logout'

run do |_opts, args, _cmd|
  system('az logout')
end
