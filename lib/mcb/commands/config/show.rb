name "show"
summary "View a config value, or all config"

run do |_opts, args, _cmd|
  if args.any?
    args.each do |name|
      puts MCB.config[name.to_sym]
    end
  else
    puts MCB.config.to_h.to_yaml
  end
end
