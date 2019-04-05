summary 'Import UCAS preferences for providers. ' \
        'Requires a filename to import as an argument.'
param :filename
usage 'import [options] <preferences_csv_filename>'
option :n, 'dry_run', "don't update anything, display what would be done"

description <<-EODESCRIPTION
  Use this command to import UCAS preferences for providers. It will display the
  changes that will be performed and a summary of those changes before prompting
  the user to continue. The -n/--dry-run` option can also be used to ensure no
  changes are performed.
EODESCRIPTION

run do |opts, args, _cmd| # rubocop: disable Metrics/BlockLength
  MCB.init_rails(opts)

  providers = Hash.new do |hash, code|
    hash[code] = Provider.find_by!(provider_code: code)
  end

  changed_preferences = Hash.new do |hash, provider|
    hash[provider] = ProviderUCASPreference.find_or_initialize_by(
      provider: provider
    )
  end
  changed_preference_count = 0

  import_filename = args.first
  import_file = File.open(import_filename)
  csv = CSV.new(import_file, headers: true)
  csv.each do |row|
    provider = providers[row['INST_CODE']]
    preference_type = translate_ucas_preference_attribute(row['PREF_TYPE'])
    if preference_type.present?
      if changed_preferences[provider].attributes_before_type_cast[preference_type] != row['PREF_VALUE']
        log_attribute_change(provider, preference_type, row['PREF_VALUE'])
        changed_preferences[provider][preference_type] = row['PREF_VALUE']
        changed_preference_count += 1
      else
        verbose "#{preference_type} value '#{row['PREF_VALUE']} " \
                "not changed for #{row['INST_CODE']}"
      end
    end
  rescue ActiveRecord::RecordNotFound => e
    MCB::LOGGER.warn(
      '[%<lineno>d] Message "%<message>s" while processing %<code>s' % {
        lineno: csv.lineno,
        message: e.message,
        code: row['INST_CODE']
      }
    )
  end

  commit_changes(changed_preferences, providers, changed_preference_count, opts)
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

def commit_changes(changed_preferences, providers, changed_preference_count, opts)
  if confirm_changes(providers, changed_preference_count, opts)
    ProviderUCASPreference.connection.transaction do
      changed_preferences.values.each(&:save!)
    end
  else
    puts 'Aborting without updating.'
  end
end

def confirm_changes(providers, changed_preference_count, opts)
  summary = "#{changed_preference_count} changed preferences for " \
            "#{providers.keys.count} providers."

  if opts[:dry_run]
    puts "#{summary} Dry-run, finishing early."
    false
  elsif changed_preference_count.positive?
    print "#{summary} Continue? "

    response = $stdin.readline
    response.match %r{^y(es?)?}i
  else
    puts "#{summary} No changes, finishing early."
    false
  end
end
