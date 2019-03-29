summary 'Import UCAS preferences for providers. Requires a filename to import as an argument.'
param :filename
option :n, 'dry_run', "don't update anything, display what would be done"

run do |opts, args, _cmd| # rubocop: disable Metrics/BlockLength
  MCB.init_rails

  providers = Hash.new do |hash, code|
    hash[code] = Provider.find_by!(provider_code: code)
  end

  changed_preferences = Hash.new do |hash, provider|
    hash[provider] = ProviderUCASPreference.find_or_initialize_by(
      provider: provider
    )
  end

  import_filename = args.first
  import_file = File.open(import_filename)
  csv = CSV.new(import_file, headers: true)
  csv.each do |row|
    provider = providers[row['INST_CODE']]
    preference_type = translate_ucas_preference_attribute(row['PREF_TYPE'])
    if preference_type.present?
      log_attribute_change(provider, preference_type, row['PREF_VALUE'])
      changed_preferences[provider][preference_type] = row['PREF_VALUE']
    end
  rescue ActiveRecord::RecordNotFound => exx
    if opts[:dry_run]
      MCB::LOGGER.warn(
        '[%<lineno>d] Message "%<message>s" while processing %<code>s' % {
          lineno: csv.lineno,
          message: exx.message,
          code: row['INST_CODE']
        }
      )
    else
      raise
    end
  end

  commit_changes(changed_preferences, opts)
end

def translate_ucas_preference_attribute(ucas_preference)
  case ucas_preference
  when 'Type of GT12 required' then 'type_of_gt12'
  when 'New UTT application alerts' then 'send_application_alerts'
  end
end

def log_attribute_change(provider, attribute, new_value)
  old_value = provider
                .ucas_preferences
                &.attributes_before_type_cast
                &.fetch(attribute)

  puts "%4<code>s %23<attribute>s: %36<old_value>s -> %-36<new_value>s" % {
    code: provider.provider_code,
    attribute: attribute,
    old_value: old_value,
    new_value: new_value
  }
end

def commit_changes(changed_preferences, opts)
  if confirm_changes(changed_preferences, opts)
    changed_preferences.values.each(&:save!)
  else
    puts 'Aborting without updating.'
  end
end

def confirm_changes(changed_preferences, opts)
  summary = "#{changed_preferences.keys.count} provider(s) changed."

  if opts[:dry_run]
    puts "#{summary} Dry-run, finishing early."
    false
  elsif changed_preferences.any?
    print "#{summary} Continue? "

    response = $stdin.readline
    response.match %r{^y(es?)?}i
  else
    puts "#{summary} No changes, finishing early."
    false
  end
end
