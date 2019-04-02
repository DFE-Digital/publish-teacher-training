name 'logout'
summary 'run az logout'

run do |_opts, _args, _cmd|
  system('az logout')
end
